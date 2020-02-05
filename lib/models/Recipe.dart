import 'package:cloud_firestore/cloud_firestore.dart';

import 'Item.dart';

class Recipe {
  String name;
  String description;
  List<Item> items;

  Recipe({this.name, this.description, this.items});

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'items': items,
  };

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Recipe(
      name: data["name"],
      description: data["description"],
      items: List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList(),
    );
  }

  factory Recipe.fromMap(Map data) {
    data = data ?? {};

    return Recipe(
      name: data["name"],
      description: data["description"],
      items: List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList(),
    );
  }
}