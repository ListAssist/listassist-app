import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'Bill.dart';

class CompletedShoppingList {
  final String id;
  final Timestamp created;
  final Timestamp completed;
  final String name;
  final String type;
  final List<Item> allItems;
  final List<Item> completedItems;
  final List<Bill> bills;

  CompletedShoppingList({this.id, this.created, this.completed, this.name, this.type, this.completedItems, this.allItems, this.bills});

  factory CompletedShoppingList.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    List<Item> tempCompletedItems = List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList();
    tempCompletedItems.removeWhere((item) => !item.bought);

    List<Item> tempAllItems = List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList();
    tempAllItems.sort((a, b) => (b.bought ? 1 : 0) - (a.bought ? 1 : 0));

    return CompletedShoppingList(
      id: doc.documentID,
      created: data["created"],
      completed: data["completed"],
      name: data["name"],
      type: data["type"],
      allItems: tempAllItems,
      completedItems: tempCompletedItems,
      bills: data["pictureURLs"]?.map<Bill>((b) => Bill.fromMap(b))?.toList()
    );
}

  factory CompletedShoppingList.fromMap(Map data) {
    data = data ?? { };

    return CompletedShoppingList(
        created: data["created"],
        completed: data["completed"],
        name: data["name"],
        type: data["type"],
        completedItems: List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList(),
        bills: data["pictureURLs"]?.map((b) => Bill.fromMap(b))?.toList()
    );
  }

  ShoppingList createNewCopy([String newName]) {
    return ShoppingList(
        created: Timestamp.now(),
        name: newName ?? this.name,
        type: "pending",
        items: this.completedItems.map((item) => Item(name: item.name, bought: item.bought = false)).toList());
  }

}