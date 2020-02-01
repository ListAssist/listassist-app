import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/main.dart';
import 'package:listassist/models/CompletedShoppingList.dart' as model2;
import 'package:listassist/models/ShoppingList.dart' as model;
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/shoppinglist/completed_shopping_list.dart';
import 'package:listassist/widgets/shoppinglist/create_shopping_list_view.dart';
import 'package:listassist/widgets/shoppinglist/shopping_list.dart';
import 'package:provider/provider.dart';

class ShoppingListView extends StatefulWidget {
  @override
  _ShoppingListView createState() => _ShoppingListView();
}

class _ShoppingListView extends State<ShoppingListView> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () async {
             /*
              // Testing automatic lists
              final HttpsCallable autoList = cloudFunctionInstance.getHttpsCallable(
                  functionName: "createAutomaticList"
              );
              try {
                dynamic resp = await autoList.call();
                if (resp.data["status"] != "Successful") {
                  InfoOverlay.showErrorSnackBar("Fehler beim Verschicken");
                } else {
                  InfoOverlay.showInfoSnackBar("Einladungen verschickt");
                }
              }catch(e) {
                InfoOverlay.showErrorSnackBar("Fehler: ${e.message}");
                print(e);
              }*/
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
              // MaterialPageRoute(builder: (context) => CreateShoppingListView()));
            },
          ),
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text("Einkaufslisten"),
            bottom: TabBar(
              tabs: [
                Tab(text: "Zu erledigen"),
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
    return lists != null ? lists.length == 0 ? Center(child: Text("Noch keine Einkaufslisten erstellt", style: Theme.of(context).textTheme.title,)) : ListView.separated(
        separatorBuilder: (ctx, i) => Divider(
          indent: 10,
          endIndent: 10,
          color: Colors.grey,
        ),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: lists.length,
        itemBuilder: (ctx, index) => ShoppingList(index: index)
    ) : SpinKitDoubleBounce(color: Colors.blueAccent,);
  }
}

class ShoppingListsHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<model2.CompletedShoppingList> lists = Provider.of<List<model2.CompletedShoppingList>>(context);
    return lists != null ? lists.length == 0 ? Center(child: Text("Noch keine Einkäufe abgeschlossen", style: Theme.of(context).textTheme.title,)) : ListView.separated(
        separatorBuilder: (ctx, i) => Divider(
          indent: 10,
          endIndent: 10,
          color: Colors.grey,
        ),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: lists.length,
        itemBuilder: (ctx, index) => CompletedShoppingList(index: index)
    ) : SpinKitDoubleBounce(color: Colors.blueAccent,);
  }
}
