import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:listassist/models/CompletedShoppingList.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';

import 'PossibleItem.dart';
import 'ScannedItem.dart';

class ScannedShoppingList {
  final double completePrice;
  final List<ScannedItem> items;
  final DateTime scanned;
  File imageFile;

  ScannedShoppingList({@required this.completePrice, @required this.items, @required this.scanned, this.imageFile});

  factory ScannedShoppingList.fromScannedItems({@required List<ScannedItem> items}) {
    /// get list price
    double price = items.map((item) => item.price).reduce((double value, double currentPrice) => value += currentPrice);

    /// Return ScannedShoppingList from Items
    return ScannedShoppingList(completePrice: price, items: items, scanned: DateTime.now());
  }

  factory ScannedShoppingList.fromJSON(String json) {
    Map<String, dynamic> obj = jsonDecode(json);

    return ScannedShoppingList(completePrice: obj["completePrice"], scanned: DateTime.parse(obj["scanned"]), items: ScannedItem.fromMapArray(obj["items"]));
  }

  String toJSON() {
    List<Map<String, dynamic>> itemsAsArrayMap = [];
    /// create map and set properties
    Map<String, dynamic> listAsMap = {
      "completePrice": completePrice,
      "scanned": scanned.toIso8601String()
    };

    /// Create JSON Array with Items inside
    items.forEach((item) => itemsAsArrayMap.add({
      "price": item.price,
      "name": item.name
    }));
    listAsMap["items"] = itemsAsArrayMap;

    return jsonEncode(listAsMap);
  }
}
