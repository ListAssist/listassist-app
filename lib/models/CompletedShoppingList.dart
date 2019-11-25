import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';

class CompletedShoppingList {
  final String id;
  final Timestamp created;
  final Timestamp completed;
  final String name;
  final String type;
  final List<Item> items;

  CompletedShoppingList({this.id, this.created, this.completed, this.name, this.type, this.items});

  factory CompletedShoppingList.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    List<Item> tempItems = List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList();
    tempItems.removeWhere((item) => !item.bought);

    return CompletedShoppingList(
      id: doc.documentID,
      created: data["created"],
      completed: data["completed"],
      name: data["name"],
      type: data["type"],
      items: tempItems,
    );
}

  factory CompletedShoppingList.fromMap(Map data) {
    data = data ?? { };

    return CompletedShoppingList(
        created: data["created"],
        completed: data["completed"],
        name: data["name"],
        type: data["type"],
        items: List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList()
    );
  }

  ShoppingList createNewCopy([String newName]) {
    return ShoppingList(
        created: Timestamp.now(),
        name: newName ?? this.name,
        type: "pending",
        items: this.items.map((item) => Item(name: item.name, bought: item.bought = false)).toList());
  }

}