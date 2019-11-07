import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/Invite.dart';
import 'package:listassist/models/ShoppingList.dart';
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

//    return db
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


  void createList(String uid, ShoppingList list) {
    var items = list.items.map((e) => e.toJson()).toList();

    _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .add({"name": list.name , "type": list.type, "items" : items});
  }

  void updateProfileName(String uid, String newName) {
    _db
        .collection('users')
        .document(uid)
        .updateData({'displayName': newName});
  }

  void updateEmail(String uid, String newEmail) {
    _db
        .collection('users')
        .document(uid)
        .updateData({'email': newEmail});
  }

}


final databaseService = DatabaseService();