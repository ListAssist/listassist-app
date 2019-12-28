import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:listassist/models/CompletedShoppingList.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/Invite.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

  Stream<User> streamProfile(FirebaseUser user) {
    print("----- READ USER -----");
    return _db
        .collection("users")
        .document(user.uid)
        .snapshots()
        .map((snap) => User.fromMap(snap.data));
  }

  Stream<List<Group>> streamGroupsFromUser(String uid) {
    print("----- READ GROUPS -----");
    //print(uid);
    /*return _db
      .collection("groups_user")
      .document(uid)
      .snapshots()
      .map((list) {
        return list.data != null ? list.data["groups"]
          .map<Stream<Group>>((groupId) => _db
            .collection("groups")
            .document(groupId)
            .snapshots()
            .map<Group>((snap) => Group.fromFirestore(snap))
          ).toList() : List<Stream<Group>>();
      });*/

    return Observable(_db
        .collection("groups_user")
        .document(uid)
        .snapshots()).switchMap((DocumentSnapshot snap) {
          return _db
            .collection("groups")
            .where(FieldPath.documentId, whereIn: snap.data["groups"])
            .snapshots()
            .map((snap) => snap.documents.map((d) => Group.fromFirestore(d)).toList());
        });
  }

  Stream<List<Invite>> streamInvites(String uid) {
    print("----- READ INVITES -----");
    return _db
        .collection("invites")
        .where("to", isEqualTo: uid)
        .where("type", isEqualTo: "pending")
        .snapshots()
        .map((snap) => snap.documents.map((d) => Invite.fromFirestore(d)).toList());
  }

  Stream<List<ShoppingList>> streamLists(String uid) {
    print("----- READ LISTS -----");
    return _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .where("type", isEqualTo: "pending")
        .snapshots()
        .map((snap) => snap.documents.map((d) => ShoppingList.fromFirestore(d)).toList());
  }

  Stream<List<CompletedShoppingList>> streamListsHistory(String uid) {
    print("----- READ COMPLETED LISTS -----");
    return _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .where("type", isEqualTo: "completed")
        .orderBy("completed", descending: true)
        .snapshots()
        .map((snap) => snap.documents.map((d) => CompletedShoppingList.fromFirestore(d)).toList());
  }

  Future<void> completeList(String uid, String listid) {
    return _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .document(listid)
        .setData({"type": "completed", "completed": Timestamp.now()}, merge: true);
  }

  Future<DocumentReference> createList(String uid, ShoppingList list) {
    var items = list.items.map((e) => e.toJson()).toList();

    return _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .add({"name": list.name , "type": list.type, "items" : items, "created": list.created});
  }

  Stream<List<ShoppingList>> streamListsFromGroup(String groupid) {
    return _db
        .collection("groups")
        .document(groupid)
        .collection("lists")
        .where("type", isEqualTo: "pending")
        .snapshots()
        .map((snap) => snap.documents.map((d) => ShoppingList.fromFirestore(d)).toList());
  }

  Future<void> updateProfileName(String uid, String newName) {
    return _db
        .collection('users')
        .document(uid)
        .updateData({'displayName': newName});
  }
  
  Future<void> updateList(String uid, ShoppingList list) {
    var items = list.items.map((e) => e.toJson()).toList();

    return _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .document(list.id)
        .setData({"name": list.name, "items" : items}, merge: true);
  }

  Future<void> deleteList(String uid, String listid) {
    return _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .document(listid)
        .setData({"type": "deleted", "deleted": Timestamp.now()}, merge: true);
  }

  Future<void> updateEmail(String uid, String newEmail) {
    return _db
        .collection('users')
        .document(uid)
        .updateData({'email': newEmail});
  }

  void addProductToProductList(String name) {
    _db
        .collection('products')
        .document()
        .setData({'name': name});
  }

}


final databaseService = DatabaseService();
final cloudFunctionInstance = CloudFunctions(app: FirebaseApp(name: "[DEFAULT]"), region: "europe-west1");