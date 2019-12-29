import 'package:cloud_firestore/cloud_firestore.dart';


class PublicUser {
  final String displayName;
  final String photoUrl;
  final String uid;

  PublicUser({this.displayName, this.photoUrl, this.uid});

  Map<String, dynamic> toJson() =>
      {
        'uid': uid,
        'displayName': displayName,
        'photoURL': photoUrl,
      };

  factory PublicUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return PublicUser(
        uid: data["uid"],
        photoUrl: data["photoURL"] ?? "",
        displayName: data["displayName"] ?? '',
    );
  }

  factory PublicUser.fromMap(Map data) {
    data = data ?? { };
    return PublicUser(
        uid: data["uid"],
        photoUrl: data["photoURL"] ?? "",
        displayName: data["displayName"] ?? "",
    );
  }
}