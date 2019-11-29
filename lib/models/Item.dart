import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String name;
  bool bought;

  Item({this.name, this.bought});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'bought': bought,
      };

  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Item(
      name: data["name"],
      bought: data["bought"],
    );
  }

  factory Item.fromMap(Map data) {
    data = data ?? { };

    return Item(
        name: data["name"],
        bought: data["bought"]
    );
  }
}