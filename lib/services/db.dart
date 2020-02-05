import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Achievement.dart';
import 'package:listassist/models/CompletedShoppingList.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/Invite.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/Product.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/models/Recipe.dart';
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
    return Observable(_db
        .collection("groups_user")
        .document(uid)
        .snapshots()).switchMap((DocumentSnapshot snap) {
          if(snap.data == null || snap.data["groups"] == null || snap.data["groups"].length == 0){
            return Stream.value(List<Group>.from([]));
          }
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

  Stream<List<Recipe>> streamRecipes(String uid) {
    print("----- READ RECIPES -----");
    return _db
        .collection("users")
        .document(uid)
        .collection("recipes")
        .snapshots()
        .map((snap) => snap.documents.map((d) => Recipe.fromFirestore(d)).toList());
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

  Future<void> completeList(String uid, ShoppingList list, [isGroup = false]) {
    Timestamp now = Timestamp.now();
    List<Item> completedItems = List.from(list.items);
    completedItems.removeWhere((item) => !item.bought);
    return Future.wait([
      _db
        .collection(isGroup ? "groups" : "users")
        .document(uid)
        .collection("lists")
        .document(list.id)
        .setData({"type": "completed", "completed": now}, merge: true),
      _db
        .collection(isGroup ? "groups" : "users")
        .document(uid)
        .collection("shopping_data")
        .document("data")
        .setData({"last": FieldValue.arrayUnion([{ "completed": now, "items": completedItems.map((item) => item.getNameAndCount()).toList()}])}, merge: true)
    ]);
  }

  Future<DocumentReference> createList(String uid, ShoppingList list, [isGroup = false]) {
    var items = list.items.map((e) => e.toJson()).toList();

    return _db
        .collection(isGroup ? "groups" : "users")
        .document(uid)
        .collection("lists")
        .add({"name": list.name , "type": list.type, "items" : items, "created": list.created});
  }

  Future<DocumentReference> createRecipe(String uid, Recipe recipe) {
    var items = recipe.items.map((e) => e.toJson()).toList();

    return _db
        .collection("users")
        .document(uid)
        .collection("recipes")
        .add({"name": recipe.name, "description" : recipe.description, "items": items});
  }

  Stream<List<ShoppingList>> streamListsFromGroup(String groupid) {
    print("----- READ GROUP LISTS -----");
    return _db
        .collection("groups")
        .document(groupid)
        .collection("lists")
        .where("type", isEqualTo: "pending")
        .snapshots()
        .map((snap) => snap.documents.map((d) => ShoppingList.fromFirestore(d)).toList());
  }

  Stream<ShoppingList> streamListFromGroup(String groupid, String listid) {
    print("----- READ GROUP LIST ${listid} -----");
    return _db
        .collection("groups")
        .document(groupid)
        .collection("lists")
        .document(listid)
        .snapshots()
        .map((snap) => ShoppingList.fromFirestore(snap));
  }

  Future<void> updateProfileName(String uid, String newName) {
    return _db
        .collection('users')
        .document(uid)
        .updateData({'displayName': newName});
  }
  
  Future<void> updateList(String uid, ShoppingList list, [isGroup = false]) async {
    var items = list.items.map((e) => e.toJson()).toList();

    return _db
        .collection(isGroup ? "groups" : "users")
        .document(uid)
        .collection("lists")
        .document(list.id)
        .setData({"name": list.name, "items" : items}, merge: true);
  }

  Future<void> addItemToList(String uid, String listId, Item newItem) async{
    List items;
    String name;
    var document = await _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .document(listId);

    await document.get().then((value) => {
      items = new List.from(value.data["items"].map((e) => Item.fromMap(e)).toList()),
      name = value.data["name"]
    });
    items.add(newItem);

    return _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .document(listId)
        .setData({"name" : name, "items" : items.map((e) => e.toJson()).toList()}, merge: true);
  }

  Future<void> removeItemFromList(String uid, String listId, String itemName) async{
    List items;
    String name;
    var document = await _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .document(listId);

    await document.get().then((value) => {
      items = new List.from(value.data["items"].map((e) => Item.fromMap(e)).toList()),
      name = value.data["name"]
    });
    items.removeWhere((i) => i.name == itemName);

    return _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .document(listId)
        .setData({"name" : name, "items" : items.map((e) => e.toJson()).toList()}, merge: true);
  }

  Future<void> changeItemCount(String uid, String listId, String itemName, int value) async{
    List items;
    String name;
    var document = await _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .document(listId);

    await document.get().then((value) => {
      items = new List.from(value.data["items"].map((e) => Item.fromMap(e)).toList()),
      name = value.data["name"]
    });
    items.forEach((i) => {
      if(i.name == itemName) {
        i.count += value
      }
    });

    return _db
        .collection("users")
        .document(uid)
        .collection("lists")
        .document(listId)
        .setData({"name" : name, "items" : items.map((e) => e.toJson()).toList()}, merge: true);
  }

  Future<List<Product>> getPopularProducts() async{
    List<Product> products;

    var document = _db
        .collection("popular_products")
        .document("products");

    await document.get().then((value) => {
      products = new List.from(value.data["products"].map((p) => Product.fromMap(p)).toList()),
    });

    return products;
  }

  Future<bool> getScannerSetting(String uid) async{
    Map settings;
    var document = _db
        .collection("users")
        .document(uid);
    await document.get().then((value) => {
      settings = value["settings"]
    });
    return settings["scanner_manual"];
  }

  Future<Map> getUserSettings(String uid) async{
    Map settings;
    var document = _db
        .collection("users")
        .document(uid);
    await document.get().then((value) => {
      settings = value["settings"]
    });
    return settings;
  }

  Future<void> updateUserSettings(String uid, Map settings) async{
    _db
        .collection("users")
        .document(uid)
        .setData({"settings": settings}, merge: true);

  }

  Future<void> deleteList(String uid, String listid) {
    return _db
        .collection(isGroup ? "groups" : "users")
        .document(uid)
        .collection("lists")
        .document(listid)
        .delete();
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

  Future<List<Achievement>> getUsersUnlockedAchievements(String uid) async{
    List<Achievement> achievements;

    var document = _db
        .collection("users")
        .document(uid);
    await document.get().then((value) => {
      achievements = new List.from(value.data["achievements"].map((p) => Achievement.fromMap(p)).toList()),
    });
    return achievements;
  }

//
//  Future<void> addToUserList(ShoppingList list, String downloadURL) {
//    return _db
//        .collection("user")
//        .document(list.id)
//        .setData({"photoURLs": FieldValue.arrayUnion([downloadURL])}, merge: true);
//  }
//
//  Future<void> addToGroupList(Group group, ShoppingList list, String downloadURL) {
//    return _db
//        .collection("groups")
//        .document(list.id)
//        .setData({"photoURLs": FieldValue.arrayUnion(["EMPTY"])}, merge: true);
//  }
}


final databaseService = DatabaseService();
final cloudFunctionInstance = CloudFunctions(app: FirebaseApp(name: "[DEFAULT]"), region: "europe-west1");