import 'package:flutter/material.dart';
import 'package:listassist/main.dart';
import 'package:listassist/widgets/shopping-list.dart';
import 'package:listassist/widgets/add-shoppinglist.dart';

class ShoppingListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddShoppinglist()));
          },
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text("Einkaufslisten"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Offen",),
              Tab(text: "Verlauf")
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            tooltip: "Open navigation menu",
            onPressed: () => mainScaffoldKey.currentState.openDrawer(),
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: <Widget>[
                ShoppingList(title: "Super liste", total: 18, bought: 4,),
                ShoppingList(title: "Schlechte liste", total: 4, bought: 3,),
                ShoppingList()
              ],
            ),
            Text("VERLAUF DER EINKAUFSLISTEN"),
          ],
        ),
      )
    );
  }
}