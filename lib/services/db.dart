import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/Invite.dart';
import 'package:listassist/models/User.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

  Stream<User> streamProfile(FirebaseUser user) {
    print("READ USER");
    return _db
        .collection("users")
        .document(user.uid)
        .snapshots()
        .map((snap) => User.fromMap(snap.data));
  }

  Stream<List<Stream<Group>>> streamGroupsFromUser(String uid) {
    print(uid);
    return _db
      .collection("groups_user")
      .document(uid)
      .snapshots()
      .map((list) {
        return list.data != null ? list.data["groups"]
          .map<Stream<Group>>((groupId) => _db
            .collection("groups")
            .document(groupId)
            .snapshots()
            .map<Group>((snap) => Group.fromMap(snap.data))
          ).toList() : List<Stream<Group>>();
      });

//    return _db
//            .collection("groups")
//            .document('89XF5ZpygJtmMxWQ0Weo')
//            .snapshots()
//            .map((snap) => Group.fromMap(snap.data));
  }

  Stream<List<Invite>> streamInvites(String uid) {
    return _db
        .collection("invites")
        .where("to", isEqualTo: uid)
        .where("type", isEqualTo: "pending")
        .snapshots()
        .map((snap) => snap.documents.map((d) => Invite.fromFirestore(d)).toList());
  }

}


final databaseService = DatabaseService();