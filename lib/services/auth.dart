import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  GoogleSignIn _googleSignIn = GoogleSignIn();
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

  /// Create a session for an user with google
  Future<FirebaseUser> googleSignIn() async {
    loading.add(true);

    /** Native Google login screen **/
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    /** Log into Firebase with Google credential **/
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser user = await _auth.signInWithCredential(credential);

    updateData(user);
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
    });
  }

  /// Logout client and kill current session
  void logout() async {
    await _auth.signOut();
  }
}

/// Expose to global namespace (not real singleton)
final AuthService authService = AuthService();

