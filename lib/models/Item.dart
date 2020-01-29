import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String name;
  int count;
  bool bought;

  Item({this.name, this.count, this.bought});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'count': count,
        'bought': bought,
      };

  Map<String, dynamic> getNameAndCount() {
    return {
      "name": name,
      "count": count
    };
  }

  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Item(
      name: data["name"],
      count: data["count"],
      bought: data["bought"],
    );
  }

  factory Item.fromMap(Map data) {
    data = data ?? { };

    return Item(
        name: data["name"],
        count: data["count"],
        bought: data["bought"]
    );
  }
}