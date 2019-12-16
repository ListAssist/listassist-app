import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/main.dart';
import 'package:listassist/models/CompletedShoppingList.dart' as model2;
import 'package:listassist/models/ShoppingList.dart' as model;
import 'package:listassist/widgets/shoppinglist/completed_shopping_list.dart';
import 'package:listassist/widgets/shoppinglist/create_shopping_list_view.dart';
import 'package:listassist/widgets/shoppinglist/shopping_list.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShoppingListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Colors.blueAccent,
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) {
                    return CreateShoppingListView();
                  },
                  transitionsBuilder: (context, animation1, animation2, child) {
                    return ScaleTransition(
                      //opacity: animation1,
                      scale: animation1,
                      alignment: Alignment.bottomRight,
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 200),
                ),
              );

              //
              //
              //
              // MaterialPageRoute(builder: (context) => CreateShoppingListView()));
            },
          ),
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text("Einkaufslisten"),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "Zu erledigen",
                ),
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
              ShoppingLists(),
              ShoppingListsHistory(),
            ],
          ),
        ));
  }
}

class ShoppingLists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<model.ShoppingList> lists = Provider.of<List<model.ShoppingList>>(context);
    return lists != null
        ? lists.length == 0
            ? Center(
                child: Text(
                "Noch keine Einkaufslisten erstellt",
                style: Theme.of(context).textTheme.title,
              ))
            : ListView.separated(
                separatorBuilder: (ctx, i) => Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Colors.grey,
                    ),
                itemCount: lists.length,
                itemBuilder: (ctx, index) => ShoppingList(index: index))
        : Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            enabled: true,
            child: Column(
              children: [0, 1, 2, 3, 4, 5, 6]
                  .map((_) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48.0,
                              height: 48.0,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 8.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 8.0,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  ),
                                  Container(
                                    width: 40.0,
                                    height: 8.0,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ))
                  .toList(),
            ));
  }
}

class ShoppingListsHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<model2.CompletedShoppingList> lists = Provider.of<List<model2.CompletedShoppingList>>(context);
    return lists != null
        ? lists.length == 0
            ? Center(
                child: Text(
                "Noch keine Einkäufe abgeschlossen",
                style: Theme.of(context).textTheme.title,
              ))
            : ListView.separated(
                separatorBuilder: (ctx, i) => Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Colors.grey,
                    ),
                itemCount: lists.length,
                itemBuilder: (ctx, index) => CompletedShoppingList(index: index))
        : SpinKitDoubleBounce(
            color: Colors.blueAccent,
          );
  }
}
