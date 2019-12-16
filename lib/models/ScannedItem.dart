
import 'package:flutter/cupertino.dart';

import 'Item.dart';
import 'PossibleItem.dart';

class ScannedItem {
  final double price;
  final String name;

  ScannedItem({@required this.price, @required this.name});

  static List<ScannedItem> itemsFromMapping(Map<Item, PossibleItem> mapping) {
    List<ScannedItem> transformedItems = [];

    mapping.keys.forEach((Item elem) =>
        transformedItems.add(ScannedItem(price: mapping[elem].price, name: elem.name))
    );

    return transformedItems;
  }

  static List<ScannedItem> fromMapArray(List<dynamic> items) {
    List<ScannedItem> transformedItems = [];

    items.forEach((item) =>
        transformedItems.add(ScannedItem(price: item["price"], name: item["name"]))
    );

    return transformedItems;
  }
}