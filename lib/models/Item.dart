import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String name;
  String category;
  int count;
  bool bought;
  double prize;

  Item({this.name, this.category, this.count, this.bought, this.prize});

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'count': count,
        'bought': bought,
        'prize': prize,
      };

  Map<String, dynamic> getNameAndCount() {
    return {
      "name": name,
      "count": count,
      "prize": prize,
      "category": category
    };
  }

  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Item(
      name: data["name"],
      category: data["category"],
      count: data["count"],
      bought: data["bought"],
      prize: data["prize"],
    );
  }

  factory Item.fromMap(Map data) {
    data = data ?? {};

    return Item(
      name: data["name"],
      category: data["category"],
      count: data["count"],
      bought: data["bought"],
      prize: data["prize"],
    );
  }

  @override
  String toString() {
    return "Item: " + name + " count=" + count.toString() + " bought=" + bought.toString();
  }
}
