import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:listassist/main.dart';
import 'package:listassist/widgets/authentication.dart';

enum AuthenticationType {Facebook, Google, Twitter}

class AuthService {

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookSignIn = FacebookLogin();
  final TwitterLogin _twitterSignIn = TwitterLogin(
    consumerKey: "nh0JWR84wnDzLDZaapWF69nrq",
    consumerSecret: "bEixX0AMS9JANn4ytlKxK3cUj2kNnILLiwE9felJY65MS2g3QT",
  );

  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _db = Firestore.instance;

  Observable<FirebaseUser> user;
  Observable<Map<String, dynamic>> profile;
  PublishSubject loading = PublishSubject();

  AuthService() {
    /** Convert onAuthStateChanged Stream to normal Observable to **/
    user = Observable(_auth.onAuthStateChanged);

    profile = user.switchMap((FirebaseUser u) {
      /**
       * Check if user is authenticated
       *
       * If so, get the user data by retrieving it from firestore
       * Otherwise return empty Observable
       */
      if (u != null) {
        return _db
            .collection("users")
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.data);
      } else {
        return Observable.just({});
      }
    });
  }

  /// Creates user with email and password
  Future<FirebaseUser> signUpWithMail(String email, String password, String displayName) async {
    try {
      AuthResult res = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = res.user;

      user.sendEmailVerification();

      DocumentReference userRef = _db
          .collection("users")
          .document(user.uid);

      userRef.setData({
        "uid": user.uid,
        "email": user.email,
        "displayName": displayName,
        "lastLogin": DateTime.now(),
      }, merge: true);

      loading.add(false);
      return user;
    } on PlatformException catch(e) {
      _ResultHandler.handlePlatformException(e);
      return null;
    }
  }

  /// Create a session for an user with email and password
  Future<FirebaseUser> signInWithMail(String email, String password) async {
    loading.add(true);

    try {
      AuthResult res = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = res.user;

      loading.add(false);
      return user;
    } on PlatformException catch(e) {
      _ResultHandler.handlePlatformException(e);
      return null;
    }
  }

  /// Create a session for an user with specific login type
  Future<FirebaseUser> signIn(AuthenticationType type) async {
    loading.add(true);

    /** Handle depending on auth type **/
    AuthCredential credential;
    switch (type) {
      case AuthenticationType.Facebook:
        /** Native Facebook login screen **/
        FacebookLoginResult result = await _facebookSignIn.logInWithReadPermissions(["email"]);

        if (_ResultHandler.handleFacebookResultError(result)) return null;

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
        TwitterLoginResult result = await _twitterSignIn.authorize();

        /// Signing in with Twitter currently doesn't work. Created Issue at firebase_auth repo
        if (_ResultHandler.handleTwitterResultError(result)) return null;

        credential = TwitterAuthProvider.getCredential(authToken: result.session.token, authTokenSecret: result.session.secret);
        break;
    }

    try {
      /** Log into Firebase with gotten from above **/
      AuthResult res = await _auth.signInWithCredential(credential);
      FirebaseUser user = res.user;
      /** Update user data if the profile picture or the email changed for example **/
      updateData(user);

      loading.add(false);
      return user;
    } on PlatformException catch (e) {
      _ResultHandler.handlePlatformException(e);
      return null;
    }
  }

  /// Updates user data from 3rd party to firestore
  void updateData(FirebaseUser user) async {
    /** Get users document **/
    DocumentReference userRef = _db.collection("users").document(user.uid);

    /** Update user data with new 3rd party data **/
    return userRef.setData({
      "uid": user.uid,
      "email": user.email,
      "photoURL": user.photoUrl,
      "displayName": user.displayName,
      "lastLogin": DateTime.now()
    }, merge: true);
  }

  /// Logout client and kill current session
  void signOut() async {
    await _auth.signOut();
  }
}

/// Expose to global namespace (not real singleton)
final AuthService authService = AuthService();

class _ResultHandler {
  static bool handleFacebookResultError(FacebookLoginResult result) {
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        return false;
      case FacebookLoginStatus.cancelledByUser:
        showInfoSnackbar(Text("Login abgebrochen, bitte versuchen Sie es erneut."));
        break;
      case FacebookLoginStatus.error:
        showError(Text("Login fehlgeschlagen"), Text("Login fehlgeschlagen, bitte versuchen Sie es erneut."));
        break;
    }
    authService.loading.add(false);
    return true;
  }

  static bool handleTwitterResultError(TwitterLoginResult result) {
    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        return false;
      case TwitterLoginStatus.cancelledByUser:
        showInfoSnackbar(Text("Login abgebrochen, bitte versuchen Sie es erneut."));
        break;
      case TwitterLoginStatus.error:
        showError(Text("Login fehlgeschlagen"), Text("Login fehlgeschlagen, bitte versuchen Sie es erneut."));
        break;
    }
    authService.loading.add(false);
    return true;
  }

  static void showInfoSnackbar(Text message, {Duration duration = const Duration(seconds: 4)}) {
    authScaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: duration,
          content: message
        )
    );
  }

  static Future showError(Text title, Text message) async {
    await showDialog(
      context: authContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title,
          content: message,
          actions: <Widget>[
            new FlatButton(
              child: new Text("Schließen"),
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
    if (e.code == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL"
        || e.code == "ERROR_EMAIL_ALREADY_IN_USE"
    ) {
      showInfoSnackbar(
        Text("Ein Account mit dieser E-Mail Adresse existiert bereits. Haben Sie vielleicht einen anderen Login-typ verwendet?"),
        duration: Duration(seconds: 6),
      );
    } else if (
    e.code == "ERROR_USER_NOT_FOUND"
        || e.code == "ERROR_WRONG_PASSWORD"
        || e.code == "ERROR_TOO_MANY_REQUESTS"
        || e.code == "ERROR_INVALID_CREDENTIAL"
    ) {
      showError(Text("Login fehlgeschlagen"), Text("Die E-Mail oder das Passwort sind fehlerhaft."));
    } else if (e.code ==  "ERROR_DISABLED"
        || e.code == "ERROR_USER_DISABLED"
    ) {
      showInfoSnackbar(Text("Dein Account ist derzeit deaktiviert."));
    } else if (
    e.code == "ERROR_NETWORK_REQUEST_FAILED" ||
        e.code == "ERROR_NETWORK_REQUEST_FAILED" ||
        e.code == "AUTHENTICATION_FAILED"
    ) {
      showError(Text("Login fehlgeschlagen"), Text("Bitte überprüfen Sie Ihre Internetverbindung."));
    } else {
      print("UNHANDLED ERROR!!!!!!!!!!!!!!!!!!");
      print(e.toString());
    }
    authService.loading.add(false);
  }
}
