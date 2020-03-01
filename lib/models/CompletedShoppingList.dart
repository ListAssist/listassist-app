import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'Bill.dart';

class CompletedShoppingList {
  final String id;
  final Timestamp created;
  final Timestamp completed;
  final String name;
  final List<Item> allItems;
  final List<Item> completedItems;
  final List<Item> uncompletedItems;
  final List<Bill> bills;

  CompletedShoppingList({this.id, this.created, this.completed, this.name, this.uncompletedItems, this.completedItems, this.allItems, this.bills});

  factory CompletedShoppingList.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    if(data == null || data.isEmpty)
      return CompletedShoppingList();

    List<Item> tempCompletedItems = List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList();
    tempCompletedItems.removeWhere((item) => !item.bought);

    List<Item> tempUncompletedItems = List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList();
    tempUncompletedItems.removeWhere((item) => item.bought);

    List<Item> tempAllItems = List.from(data["items"] ?? []).map((x) => Item.fromMap(x)).toList();
    tempAllItems.sort((a, b) => (b.bought ? 1 : 0) - (a.bought ? 1 : 0));

    return CompletedShoppingList(
      id: doc.documentID,
      created: data["created"],
      completed: data["completed"],
      name: data["name"],
      uncompletedItems: tempUncompletedItems,
      completedItems: tempCompletedItems,
      allItems: tempAllItems,
      bills: data["pictureURLs"]?.map<Bill>((url) => Bill.fromURL(url))?.toList() ?? []
    );
  }

  ShoppingList createNewCopy([String newName, bool copyCompleted = false, bool copyUncompleted = false]) {
    List<Item> toCopy = (copyCompleted && copyUncompleted)
        ? allItems
        : copyUncompleted
          ? uncompletedItems
          : completedItems;
    print(toCopy);
    return ShoppingList(
        created: Timestamp.now(),
        name: newName ?? this.name,
        type: "pending",
        items: toCopy.map((item) =>
            Item(
                name: item.name,
                bought: false,
                prize: item.prize,
                count: item.count,
                category: item.category
            )).toList());
  }

}