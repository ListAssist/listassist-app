import 'package:cloud_firestore/cloud_firestore.dart';


class User {
  final String email;
  final String displayName;
  final String photoUrl;
  final String uid;
  final Timestamp lastLogin;

  User({this.lastLogin, this.email, this.displayName, this.photoUrl, this.uid});

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return User(
        uid: data["uid"],
        email: data["email"],
        photoUrl: data["photoURL"] ?? "",
        displayName: data["displayName"] ?? '',
        lastLogin: data["lastLogin"] ?? null
    );
  }

  factory User.fromMap(Map data) {
    data = data ?? { };
    return User(
        uid: data["uid"],
        email: data["email"],
        photoUrl: data["photoURL"] ?? "",
        displayName: data["displayName"] ?? "",
        lastLogin: data["lastLogin"] ?? null
    );
  }
}