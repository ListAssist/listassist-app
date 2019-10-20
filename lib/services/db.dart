import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/User.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

  Stream<User> streamProfile(FirebaseUser user) {
    return _db
        .collection("users")
        .document(user.uid)
        .snapshots()
        .map((snap) => User.fromMap(snap.data));
  }

  Stream<Group> streamGroupsFromUser() {
    return _db
        .collection("groups")
        .document('89XF5ZpygJtmMxWQ0Weo')
        .snapshots()
        .map((snap) => Group.fromMap(snap.data));
  }

}


final databaseService = DatabaseService();