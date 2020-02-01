import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  String name;
  String description;
  String category;
  int count;
  bool bought;
  double prize;

  Recipe({this.name, this.description, this.category, this.count, this.bought, this.prize});

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'category': category,
    'count': count,
    'bought': bought,
    'prize': prize,
  };

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Recipe(
      name: data["name"],
      description: data["description"],
      category: data["category"],
      count: data["count"],
      bought: data["bought"],
      prize: data["prize"],
    );
  }

  factory Recipe.fromMap(Map data) {
    data = data ?? {};

    return Recipe(
      name: data["name"],
      description: data["description"],
      category: data["category"],
      count: data["count"],
      bought: data["bought"],
      prize: data["prize"],
    );
  }
}