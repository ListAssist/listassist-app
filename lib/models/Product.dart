import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  bool category;

  Product({this.name, this.category});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'category': category,
      };

  factory Product.fromMap(Map data) {
    data = data ?? { };

    return Product(
        name: data["name"],
        category: data["category"]
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Product(
      name: data["name"],
      category: data["category"],
    );
  }
}