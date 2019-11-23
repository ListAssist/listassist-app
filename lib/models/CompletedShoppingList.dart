import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listassist/models/Item.dart';

class CompletedShoppingList {
  final String id;
  final Timestamp created;
  final String name;
  final String type;
  final List<Item> items;

  CompletedShoppingList({this.id, this.created, this.name, this.type, this.items});

  factory CompletedShoppingList.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return CompletedShoppingList(
      id: doc.documentID,
      created: data["created"],
      name: data["name"],
      type: data["type"],
      items: List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList(),
    );
  }

  factory CompletedShoppingList.fromMap(Map data) {
    data = data ?? { };

    return CompletedShoppingList(
        created: data["created"],
        name: data["name"],
        type: data["type"],
        items: List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList()
    );
  }
}