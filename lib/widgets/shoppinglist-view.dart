import 'package:flutter/material.dart';
import 'package:shoppy/widgets/shopping-list.dart';
import 'package:shoppy/widgets/sidebar.dart';

class ShoppingListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Einkaufslisten")
      ),
      body: Column(
        children: <Widget>[
          ShoppingList(title: "Super liste",),
          ShoppingList()
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      drawer: Sidebar(),
    );
  }
}