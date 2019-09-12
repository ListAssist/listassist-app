import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:rxdart/rxdart.dart';

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

  Future<FirebaseUser> signUpWithMail(String email, String password, String username) {


  }

  /// Create a session for an user with email and password
  Future<FirebaseUser> signInWithMail(String email, String password) async {
    loading.add(true);

    FirebaseUser user = await _auth.signInWithEmailAndPassword(email: email, password: password);
    print(user.photoUrl);

    loading.add(false);
    return user;
  }

  /// Create a session for an user with specific login type
  Future<FirebaseUser> signIn(AuthenticationType type) async {
    loading.add(true);

    /** Handle depending on auth type **/
    AuthCredential credential;
    switch (type) {
      case AuthenticationType.Facebook:
        /** Native Facebook login screen **/
        FacebookLoginResult result = await _facebookSignIn.logInWithReadPermissions(['email']);

        /// TODO: Could handle exit data for errors result.status to show in UI

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

        /// TODO: Could handle exit data for errors result.status to show in UI
        /// Signing in with Twitter currently doesn't work. Created Issue at firebase_auth repo

        credential = TwitterAuthProvider.getCredential(authToken: result.session.token, authTokenSecret: result.session.secret);
        break;
    }

    /** Log into Firebase with gotten from above **/
    FirebaseUser user = await _auth.signInWithCredential(credential);

    /** Update user data if the profile picture or the email changed for example **/
    updateData(user);

    loading.add(false);
    return user;
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

