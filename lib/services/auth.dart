import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:rxdart/rxdart.dart';
import 'package:listassist/widgets/authentication/authentication.dart';

enum AuthenticationType {Facebook, Google, Twitter}

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookSignIn = FacebookLogin();
//  final TwitterLogin _twitterSignIn = TwitterLogin(
//    consumerKey: "nh0JWR84wnDzLDZaapWF69nrq",
//    consumerSecret: "bEixX0AMS9JANn4ytlKxK3cUj2kNnILLiwE9felJY65MS2g3QT",
//  );

  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _db = Firestore.instance;

  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;
  Observable<User> get userDoc => Observable(user).switchMap(
      (FirebaseUser user)  {
        if (user != null) {
          return databaseService.streamProfile(user);
        } else {
          return Observable.just(null);
        }
      }
  );

  BehaviorSubject<bool> loading = BehaviorSubject<bool>.seeded(false);

  AuthService();

  /// Creates user with email and password
  Future<FirebaseUser> signUpWithMail(String email, String password, String displayName) async {
    try {
      AuthResult res = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = res.user;

      user.sendEmailVerification();

      DocumentReference userRef = _db
          .collection("users")
          .document(user.uid);

      await userRef.setData({
        "uid": user.uid,
        "email": user.email,
        "displayName": displayName,
        "lastLogin": DateTime.now(),

      }, merge: true);

      return user;
    } on PlatformException catch(e) {
      ResultHandler.handlePlatformException(e);
      return null;
    }
  }

  /// Create a session for an user with email and password
  Future<FirebaseUser> signInWithMail(String email, String password) async {
    try {
      AuthResult res = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = res.user;

      //TODO: Email verify error
      DocumentReference userRef = _db
          .collection("users")
          .document(user.uid);

      await userRef.setData({
        "lastLogin": DateTime.now(),
      }, merge: true);

      loading.add(false);
      return user;
    } on PlatformException catch(e) {
      ResultHandler.handlePlatformException(e);
      return null;
    }
  }

  /// Create a session for an user with specific login type
  Future<FirebaseUser> signIn(AuthenticationType type) async {
    loading.add(true);

    /** Handle depending on auth type **/
    AuthCredential credential;
    try {
      switch (type) {
        case AuthenticationType.Facebook:
        /** Native Facebook login screen **/
          FacebookLoginResult result = await _facebookSignIn.logIn(["email"]);

          if (ResultHandler.handleFacebookResultError(result)) return null;

          credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
          break;
        case AuthenticationType.Google:
        /** Native Google login screen **/
          GoogleSignInAccount googleUser = await _googleSignIn.signIn();
          GoogleSignInAuthentication googleAuth = await googleUser.authentication;

          credential = GoogleAuthProvider.getCredential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          break;
        case AuthenticationType.Twitter:
//          TwitterLoginResult result = await _twitterSignIn.authorize();
//
//          /// Signing in with Twitter currently doesn't work. Created Issue at firebase_auth repo
//          if (ResultHandler.handleTwitterResultError(result)) return null;
//
//          credential = TwitterAuthProvider.getCredential(authToken: result.session.token, authTokenSecret: result.session.secret);
//          break;
      }
    } catch (e) {
      InfoOverlay.showInfoSnackBar("Es ist ein Fehler aufgetreten bei der Anmeldemethode die du gewählt hast. Versuche es erneut oder versuche eine andere Anmeldemethode aus.");
      loading.add(false);
      return null;
    }

    try {
      /** Log into Firebase with gotten from above **/
      AuthResult res = await _auth.signInWithCredential(credential);
      FirebaseUser user = res.user;
      /** Update user data if the profile picture or the email changed for example **/
      updateData(user, type);

      loading.add(false);
      return user;
    } on PlatformException catch (e) {
      ResultHandler.handlePlatformException(e);
      return null;
    }
  }

  /// Updates user data from 3rd party to firestore
  void updateData(FirebaseUser user, AuthenticationType type) async {
    /** Get users document **/
    DocumentReference userRef = _db.collection("users").document(user.uid);

    /** Update user data with new 3rd party data **/
    return await userRef.setData({
      "uid": user.uid,
      "email": user.email,
      "photoURL": user.photoUrl,
      "displayName": user.displayName,
      "lastLogin": DateTime.now(),
      "type": authenticationEnumToString(type)
    }, merge: true);
  }

  Future<String> reauthenticateUser(FirebaseUser firebaseUser, String password) async {
    String currentEmail = (await _auth.currentUser()).email;

    print("currentEmail: " + currentEmail);
    try{
      AuthCredential credential = EmailAuthProvider.getCredential(email: currentEmail, password: password);
      await firebaseUser.reauthenticateWithCredential(credential);
      return "loggedin";
    } on PlatformException catch(e) {
      print(e.toString());
      return "Falsches Passwort";
    }

  }

  Future<void> updateEmail(FirebaseUser firebaseUser, String newEmail) async {
    return firebaseUser.updateEmail(newEmail);
  }

  Future<void> updatePassword(FirebaseUser firebaseUser, String newPassword) async {
    return firebaseUser.updatePassword(newPassword);
  }

  Future setProfilePicture(User user, String newPhotoURL) async{
    /** Get users document **/
    DocumentReference userRef = _db.collection("users").document(user.uid);

    /** Update user profile picture with new **/
    return await userRef.setData({
      "photoURL": newPhotoURL,
    }, merge: true);
  }

  /// Logout client and kill current session
  void signOut() async {
    await _auth.signOut();
  }

  String authenticationEnumToString(AuthenticationType type) {
    String finalString = "";
    switch (type) {
      case AuthenticationType.Facebook:
        finalString = "facebook";
        break;
      case AuthenticationType.Google:
        finalString = "google";
        break;
      case AuthenticationType.Twitter:
        finalString = "twitter";
        break;
    }
    return finalString;
  }
}

/// Expose to global namespace (not real singleton)
final AuthService authService = AuthService();

class ResultHandler {
  static bool handleFacebookResultError(FacebookLoginResult result) {
    authService.loading.add(false);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        return false;
      case FacebookLoginStatus.cancelledByUser:
        InfoOverlay.showInfoSnackBar("Login abgebrochen, bitte versuchen Sie es erneut.");
        break;
      case FacebookLoginStatus.error:
        showError(Text("Login fehlgeschlagen"), Text("Login fehlgeschlagen, bitte versuchen Sie es erneut."));
        break;
    }

    return true;
  }

//  static bool handleTwitterResultError(TwitterLoginResult result) {
//    authService.loading.add(false);
//
//    switch (result.status) {
//      case TwitterLoginStatus.loggedIn:
//        return false;
//      case TwitterLoginStatus.cancelledByUser:
//        InfoOverlay.showInfoSnackBar("Login abgebrochen, bitte versuchen Sie es erneut.");
//        break;
//      case TwitterLoginStatus.error:
//        showError(Text("Login fehlgeschlagen"), Text("Login fehlgeschlagen, bitte versuchen Sie es erneut."));
//        break;
//    }
//    return true;
//  }

  static Future<void> showError(Text title, Text message) async {
    await showDialog(
      context: authContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title,
          content: message,
          actions: <Widget>[
            FlatButton(
              child: Text("Schließen"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  static void handlePlatformException(PlatformException e) {
    authService.loading.add(false);

    if (
        e.code == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL" ||
        e.code == "ERROR_EMAIL_ALREADY_IN_USE"
    ) {
      InfoOverlay.showInfoSnackBar(
        "Ein Account mit dieser E-Mail Adresse existiert bereits. Haben Sie vielleicht einen anderen Login-typ verwendet?"
      );
    } else if (
        e.code == "ERROR_USER_NOT_FOUND" ||
        e.code == "ERROR_WRONG_PASSWORD" ||
        e.code == "ERROR_TOO_MANY_REQUESTS" ||
        e.code == "ERROR_INVALID_CREDENTIAL"
    ) {
      showError(Text("Login fehlgeschlagen"), Text("Die E-Mail oder das Passwort sind fehlerhaft."));
    } else if (
        e.code ==  "ERROR_DISABLED" ||
        e.code == "ERROR_USER_DISABLED"
    ) {
      InfoOverlay.showInfoSnackBar("Dein Account ist derzeit deaktiviert.");
    } else if (
        e.code == "ERROR_NETWORK_REQUEST_FAILED" ||
        e.code == "ERROR_NETWORK_REQUEST_FAILED" ||
        e.code == "AUTHENTICATION_FAILED"
    ) {
      showError(Text("Login fehlgeschlagen"), Text("Bitte überprüfen Sie Ihre Internetverbindung."));
    } else if (e.code.contains("Error performing")) {
      InfoOverlay.showInfoSnackBar("Please verify your email by clicking on the link which was sent to your email you entered.");
    } else {
        print("UNHANDLED ERROR!!!!!!!!!!!!!!!!!!");
        print(e.toString());
    }
  }
}
