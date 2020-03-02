import 'package:cloud_firestore/cloud_firestore.dart';

import 'Item.dart';

class Recipe {
  String id;
  String name;
  String description;
  List<Item> items;

  Recipe({this.id, this.name, this.description, this.items,});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'items': items,
  };

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Recipe(
      id: doc.documentID,
      name: data["name"],
      description: data["description"],
      items: List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList(),
    );
  }

  factory Recipe.fromMap(Map data) {
    data = data ?? {};

    return Recipe(
      id: data["id"],
      name: data["name"],
      description: data["description"],
      items: List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList(),
    );
  }

  bool hasItem(String itemName) {
    return items.indexWhere((i) => i.name == itemName) != -1;
  }

  int getItemCount(String itemName) {
    return items.where((i) => i.name == itemName).toList()[0].count;
  }

  void addItem(String productName, String category){
    items.add(new Item(name: productName, category: category, count: 1, bought: false, price: 0));
  }

  void changeItemCount(String itemName, int value) {
    if(hasItem(itemName)) {
      items.where((i) => i.name == itemName).toList()[0].count += value;
    }
  }

  void removeItem(String itemName) {
    items.removeWhere((i) => i.name == itemName);
  }
}