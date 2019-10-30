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

  Stream<Group> streamGroupsFromUser(String uid) {
//    String[] groupIds =
      Stream<List<Group>> groups;
        _db
        .collection("groups_user")
        .document(uid)
        .get()
        .then((snap) {
          print(snap.data);
//          for(int i = 0; i < snap.data["groups"].length; i++){
//            groups.add(_db
//                .collection("groups")
//                .snapshots()
//                .snapshots()
//                .map((snap) => Group.fromMap(snap.data));)
//          }
        });

    return _db
            .collection("groups")
            .document('89XF5ZpygJtmMxWQ0Weo')
            .snapshots()
            .map((snap) => Group.fromMap(snap.data));
  }

  Stream<List<Invite>> streamInvites(String uid) {
    return _db
        .collection("invites")
        .where("to", isEqualTo: uid)
        .where("type", isEqualTo: "pending")
        .snapshots()
        .map((snap) => snap.documents.map((d) => Invite.fromMap(d.data)).toList());
  }

}


final databaseService = DatabaseService();