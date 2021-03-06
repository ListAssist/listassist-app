import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:listassist/assets/custom_colors.dart';
import 'package:listassist/main.dart';
import 'package:listassist/models/CompletedShoppingList.dart' as model2;
import 'package:listassist/models/ShoppingList.dart' as model;
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:listassist/widgets/shoppinglist/completed_shopping_list.dart';
import 'package:listassist/widgets/shoppinglist/create_shopping_list_view.dart';
import 'package:listassist/widgets/shoppinglist/shopping_list.dart';
import 'package:provider/provider.dart';

class ShoppingListView extends StatefulWidget {
  @override
  _ShoppingListView createState() => _ShoppingListView();
}

class _ShoppingListView extends State<ShoppingListView> {

  bool first = true;
  //TODO: Invalid value: Not in range 0..1, inclusive: 2 on group delete

  @override
  Widget build(BuildContext context) {
    if(first) {
      User user = Provider.of<User>(context);
      if(user.settings != null) {
        if (user.settings["ai_enabled"]) {
          if (user.settings["ai_interval"] != null) {
            if (user.lastAutomaticallyGenerated == null) {
              _createAutomaticList();
            } else {
              DateTime nextList = user.lastAutomaticallyGenerated.toDate().add(
                  Duration(days: user.settings["ai_interval"]));
              if (DateTime.now().isAfter(nextList)) {
                _createAutomaticList();
              }
            }
          }
        }
      }
      first = false;
    }
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Provider.of<User>(context).settings["theme"] == "Grün" ? CustomColors.shoppyGreen : Theme.of(context).colorScheme.primary,
            onPressed: () async {
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
            backgroundColor: Provider.of<User>(context).settings["theme"] == "Blau" ? Theme.of(context).colorScheme.primary : CustomColors.shoppyGreen,
            title: Text("Einkaufslisten"),
            flexibleSpace: Provider.of<User>(context).settings["theme"] == "Verlauf" ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: <Color>[
                    CustomColors.shoppyBlue,
                    CustomColors.shoppyLightBlue,
                  ])
              )) : Container(),
            bottom: TabBar(
              indicatorColor: Colors.white,
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

  _createAutomaticList() async {
    print("Creating automatic list");
    final HttpsCallable autoList = cloudFunctionInstance.getHttpsCallable(
        functionName: "createAutomaticList"
    );
    try {
      dynamic resp = await autoList.call({
        "groupid": null
      });
      if (resp.data["status"] != "Successful") {
        print(resp);
        //InfoOverlay.showErrorSnackBar("Fehler beim Erstellen der Automatischen Einkaufsliste");
      } else {
        InfoOverlay.showInfoSnackBar("Automatische Einkaufsliste wurde erstellt");
      }
    }catch(e) {
      //InfoOverlay.showErrorSnackBar("Fehler: ${e.message}");
    }
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
    ) : ShoppyShimmer();
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
    ) : ShoppyShimmer();
  }
}
