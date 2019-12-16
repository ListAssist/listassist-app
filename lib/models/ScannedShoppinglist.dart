import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listassist/models/CompletedShoppingList.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';

import 'PossibleItem.dart';

class ScannedShoppingList {
  final double completePrice;
  final List<PossibleItem> items;
  final Timestamp scanned;

  ScannedShoppingList({this.completePrice, this.items, this.scanned});

  factory ScannedShoppingList.fromJSON(String jsonString) {
    Map data = doc.data;

    List<Item> tempCompletedItems = List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList();
    tempCompletedItems.removeWhere((item) => !item.bought);

    List<Item> tempAllItems = List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList();
    tempAllItems.sort((a, b) => (b.bought ? 1 : 0) - (a.bought ? 1 : 0));

    return null;
  }

  factory ScannedShoppingList.fromMap(Map data) {
    data = data ?? { };

    return null;
  }

  factory ScannedShoppingList.fromItems(List<PossibleItem> items) {
    double price = items.map((item) => item.price).reduce((double value, double currentPrice) => value += currentPrice);
    return ScannedShoppingList(completePrice: price, items: items, scanned: Timestamp.now());
  }

  ShoppingList createNewCopy([String newName]) {
    return ShoppingList(
        created: Timestamp.now(),
        name: newName ?? this.name,
        type: "pending",
        items: this.completedItems.map((item) => Item(name: item.name, bought: item.bought = false)).toList());
  }

}
