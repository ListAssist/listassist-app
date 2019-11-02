import 'package:flutter/material.dart';
import 'package:listassist/main.dart';
import 'package:listassist/widgets/shopping-list.dart';
import 'package:listassist/widgets/add-shoppinglist.dart';

class ShoppingListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> listItem = List();
    listItem.add(ShoppingList(title: "Automatische Einkaufsliste", total: 18, bought: 0,));
    listItem.add(ShoppingList(title: "Grillen am Wochenende", total: 4, bought: 3,));
    listItem.add(ShoppingList());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddShoppinglist()));
          },
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text("Einkaufslisten"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Zu erledigen",),
              Tab(text: "Erledigt")
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
            Text("VERLAUF DER EINKAUFSLISTEN"),
          ],
        ),
      )
    );
  }
}