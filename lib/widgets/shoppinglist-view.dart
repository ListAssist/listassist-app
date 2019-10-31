import 'package:flutter/material.dart';
import 'package:listassist/main.dart';
import 'package:listassist/widgets/shopping-list.dart';

class ShoppingListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> listItem = List();
    listItem.add(ShoppingList(title: "Super liste", total: 18, bought: 4,));
    listItem.add( ShoppingList(title: "Schlechte liste", total: 4, bought: 3,));
    listItem.add(ShoppingList());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            ListView.separated(
              separatorBuilder: (ctx, i) => Divider(
                indent: 10,
                endIndent: 10,
                color: Colors.grey,
              ),
              itemCount: listItem.length,
              itemBuilder: (ctx, index) => listItem[index]
            ),
            Text("VERLAUF DER EINKAUFSLISTEN")
          ],
        ),
      )
    );
  }
}