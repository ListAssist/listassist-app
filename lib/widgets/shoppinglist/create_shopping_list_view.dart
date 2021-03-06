import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/achievements.dart';
import 'package:listassist/services/connectivity.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/shoppinglist/search_items_view_new.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:provider/provider.dart';

class CreateShoppingListView extends StatefulWidget {
  final bool isGroup;
  final int groupIndex;
  CreateShoppingListView({this.isGroup = false, this.groupIndex});
  @override
  _CreateShoppingListView createState() => _CreateShoppingListView();
}

class _CreateShoppingListView extends State<CreateShoppingListView> {

  bool buttonDisabled = false;

  List<ShoppingList> _lists;
  User _user;
  String _uid;

  @override
  Widget build(BuildContext context) {
    Color _backgroundColor = /*Colors.blueAccent[400];*/ Theme.of(context).primaryColor;
    _user = Provider.of<User>(context);

    if(!widget.isGroup) {
      _uid = _user.uid;
      _lists = Provider.of<List<ShoppingList>>(context);
    }else {
      _uid = Provider.of<List<Group>>(context)[widget.groupIndex].id;
      _lists = Provider.of<List<ShoppingList>>(context);
    }

    RegExp defaultListName = new RegExp(r"Einkaufsliste #[0-9]+");

    TextEditingController _nameController = new TextEditingController();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: _backgroundColor,
          leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0,
        ),
        body: Column(children: <Widget>[
          Container(
            height: 200.0,
            child: Stack(
              children: <Widget>[
                Container(
                  color: _backgroundColor,
                  width: MediaQuery.of(context).size.width,
                  height: 200.0,
                ),
                Container(
                  height: 150,
                  margin: EdgeInsets.only(left: 20, right: 20, top: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: 120,
                  right: 40,
                  height: 40,
                  child: Container(
                    width: 130,
                    height: 40,
                    child: ProgressButton(
                      child: Text(
                        "Liste erstellen",
                        style: TextStyle(color: Colors.white),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: Theme.of(context).primaryColor,
                      progressIndicatorColor: Colors.white,
                      progressIndicatorSize: 20,
                      onPressed: (AnimationController controller) async {
                        controller.forward();
                        bool connected = await connectivityService.testInternetConnection();
                        if (!connected) {
                          //I am NOT connected
                          controller.reverse();
                          InfoOverlay.showErrorSnackBar("Keine Internetverbindung");
                        } else if(!buttonDisabled){
                          //I am connected to the Internet
                          buttonDisabled = true;
                          ShoppingList _newShoppingList;
                          if (_nameController.text.length > 0) {
                            String name = _nameController.text;
                            _newShoppingList = new ShoppingList(
                              id: "",
                              created: Timestamp.now(),
                              name: name,
                              type: "pending",
                              items: new List(),
                            );
                          } else {
                            List<ShoppingList> listen = _lists;
                            listen = listen.where((i) => defaultListName.hasMatch(i.name)).toList();
                            print(listen);
                            int lastId = 0;
                            listen.forEach((l) => {
                                  if (int.parse(l.name.split("#")[1]) > lastId) {lastId = int.parse(l.name.split("#")[1])}
                                });
                            _newShoppingList = new ShoppingList(
                              id: "",
                              created: Timestamp.now(),
                              name: "Einkaufsliste #" + (lastId + 1).toString(),
                              type: "pending",
                              items: [],
                            );
                          }

                          DocumentReference docRef = await databaseService.createList(_uid, _newShoppingList, widget.isGroup);
                          InfoOverlay.showInfoSnackBar("Einkaufsliste ${_newShoppingList.name} erstellt");
                          achievementsService.checkListName(_user, _newShoppingList.name);
                          achievementsService.listCreated(_user);
                          controller.reverse();
                          Navigator.pop(context);

                          /*print("DOCREFFFF  " + docRef.documentID);
                          lists.forEach((l) => {
                            print(l.id)
                          });*/

                          //_newShoppingList.id = docRef.documentID;
                          ShoppingList _newShoppingListWithNewID = new ShoppingList(
                            id: docRef.documentID,
                            created: _newShoppingList.created,
                            name: _newShoppingList.name,
                            items: _newShoppingList.items,
                            type: _newShoppingList.type
                          );

                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          widget.isGroup ?
                          StreamProvider<ShoppingList>.value(
                            value: databaseService.streamListFromGroup("${widget.groupIndex}", docRef.documentID),
                            child: SearchItemsViewNew(list: _newShoppingListWithNewID, isGroup: true, groupid: _uid),
                          ) : SearchItemsViewNew(list: _newShoppingListWithNewID)));
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 40.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: EdgeInsets.only(top: 10, left: 50.0, right: 50.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.0), color: Colors.white),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(border: UnderlineInputBorder(), hintText: "Name", contentPadding: EdgeInsets.only(top: 17, left: 5, right: 17, bottom: 10)),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: _backgroundColor,
              width: MediaQuery.of(context).size.width,
              child: Stack(children: []),
            ),
          )
        ]));
  }

}
