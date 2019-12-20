import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listassist/models/Item.dart';

class ShoppingList {
  final String id;
  final Timestamp created;
  final String name;
  final String type;
  final List<Item> items;

  ShoppingList({this.id, this.created, this.name, this.type, this.items});

  factory ShoppingList.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return ShoppingList(
      id: doc.documentID,
      created: data["created"],
      name: data["name"],
      type: data["type"],
      items: List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList(),
    );
  }

  factory ShoppingList.fromMap(Map data) {
    data = data ?? { };

    return ShoppingList(
        created: data["created"],
        name: data["name"],
        type: data["type"],
        items: List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList()
    );
  }

  bool hasItem(String itemName) {
    return items.indexWhere((i) => i.name == itemName) != -1;
  }

  int getItemCount(String itemName) {
    return items.where((i) => i.name == itemName).toList()[0].count;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Name: $name, Items: ${items.map((i) => i.name).join(", ")}";
  }
}