import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/CompletedShoppingList.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/group/edit_group.dart';
import 'package:listassist/widgets/group/group_userlist.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:listassist/widgets/shoppinglist/create_shopping_list_view.dart';
import 'package:listassist/widgets/shoppinglist/shopping_list.dart' as w;
import 'package:listassist/widgets/shoppinglist/completed_shopping_list.dart' as w2;
import 'package:progress_indicator_button/progress_button.dart';
import 'package:provider/provider.dart';

class GroupDetail extends StatefulWidget {
  final index;
  GroupDetail({this.index});
  @override
  _GroupDetail createState() => _GroupDetail();
}
enum GroupAction { edit, leave, delete}


Group _group;
bool _useCache = false;

class _GroupDetail extends State<GroupDetail> {
  String username;
  bool _isInviting = false;

  @override
  Widget build(BuildContext context) {
    if (!_useCache) {
      _group = Provider.of<List<Group>>(context)[widget.index];
    }
    User user = Provider.of<User>(context);
    username = user.displayName;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(_group.title),
          actions: <Widget>[
            GroupMenu(uid: user.uid)
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list)),
              Tab(icon: Icon(Icons.playlist_add_check)),
              Tab(icon: Icon(Icons.group))
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamProvider<List<ShoppingList>>.value(
              value: databaseService.streamLists(_group.id, true),
              child: ShoppingLists(groupindex: widget.index),
            ),
            StreamProvider<List<CompletedShoppingList>>.value(
              value: databaseService.streamListsHistory(_group.id, true),
              child: ShoppingListsHistory(groupindex: widget.index),
            ),
            GroupUserList(index: widget.index)
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Transform.scale(
                  scale: 0.75,
                  child: FloatingActionButton(
                    onPressed: () {
                      _showInviteDialog();
                    },
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person_add, color: Colors.grey,),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                   Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return StreamProvider<List<ShoppingList>>.value(
                      value: databaseService.streamLists(_group.id, true),
                      child: CreateShoppingListView(isGroup: true, groupIndex: widget.index),
                    );
                  }));
                },
                backgroundColor: Colors.green,
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInviteDialog() async {
    TextEditingController _addressController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Mitglieder hinzufügen"),
          content: SingleChildScrollView(
            child: TextField(
              controller: _addressController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.all(3),
                labelText: "Email Adresse",
              ),
            )
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text("Abbrechen"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Container(
              width: 100,
              height: 40,
              child: ProgressButton(
                child: Text("Einladen", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                onPressed: _isInviting ? null : (AnimationController controller) async {
                  controller.forward();
                  setState(() {
                    _isInviting = true;
                  });
                  final HttpsCallable invite = cloudFunctionInstance.getHttpsCallable(
                      functionName: "inviteUsers"
                  );
                  try {
                    dynamic resp = await invite.call(<String, dynamic>{
                      "targetemails": [_addressController.text],
                      "groupid": _group.id,
                      "groupname": _group.title,
                      "from": username,
                    });
                    if (resp.data["status"] != "Successful") {
                      InfoOverlay.showErrorSnackBar("Fehler beim Verschicken");
                    } else {
                      InfoOverlay.showInfoSnackBar("Einladungen verschickt");
                      Navigator.pop(context);
                    }
                  } catch(e) {
                    InfoOverlay.showErrorSnackBar("Fehler: ${e.message}");
                  } finally {
                    _isInviting = false;
                    controller.reverse();
                  }
                },
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: Colors.white,
                progressIndicatorColor: Theme.of(context).colorScheme.primary,
                progressIndicatorSize: 20,
              ),
            ),
          ],
        );
      },
    );
  }

}


class GroupMenu extends StatelessWidget {
  final String uid;
  GroupMenu({this.uid});


  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<GroupAction>(
      onSelected: (GroupAction result) async {
        if(result == GroupAction.leave){
          try {
            final HttpsCallable leave = cloudFunctionInstance.getHttpsCallable(
                functionName: "leaveGroup"
            );
            _useCache = true;
            _group = Group(
              id: _group.id,
              creator: _group.creator,
              members: _group.members,
              title: _group.title
            );
            dynamic resp = await leave.call(<String, dynamic>{
              "groupid": _group.id
            });
            if (resp.data["status"] == "Failed") {
              InfoOverlay.showErrorSnackBar("Fehler beim Verlassen der Gruppe");
              _useCache = false;
            } else {
              InfoOverlay.showInfoSnackBar("Gruppe verlassen");
              Navigator.pop(context);
              _useCache = false;
            }
          }catch(e) {
            InfoOverlay.showErrorSnackBar("Fehler: ${e.message}");
          }
        }else if(result == GroupAction.edit) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Provider<Group>.value(
                  value: _group,
                  child: EditGroup()),
            )
          );
        }else if(result == GroupAction.delete) {
          try {
            final HttpsCallable delete = cloudFunctionInstance.getHttpsCallable(
                functionName: "deleteGroup"
            );
            dynamic resp = await delete.call(<String, dynamic>{
              "groupid": _group.id
            });
            if (resp.data["status"] == "Failed") {
              InfoOverlay.showErrorSnackBar("Fehler beim Löschen der Gruppe");
            } else {
              InfoOverlay.showInfoSnackBar("Gruppe gelöscht");
              Navigator.pop(context);
            }
          }catch(e) {
            InfoOverlay.showErrorSnackBar("Fehler: ${e.message}");
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<GroupAction>>[
        PopupMenuItem<GroupAction>(
          value: GroupAction.edit,
          enabled: _group.creator.uid == uid,
          child: Text('Gruppe bearbeiten'),
        ),
        PopupMenuItem<GroupAction>(
          value: GroupAction.delete,
          enabled: _group.creator.uid == uid,
          child: Text('Gruppe löschen'),
        ),
        PopupMenuItem<GroupAction>(
          value: GroupAction.leave,
          child: Text('Gruppe verlassen'),
        ),
      ],
    );
  }

}

class ShoppingLists extends StatelessWidget {
  final int groupindex;
  ShoppingLists({this.groupindex});

  bool first = true;

  @override
  Widget build(BuildContext context) {
    if(first) {
      Group group = Provider.of<List<Group>>(context)[groupindex];
      if(group.settings != null) {
        //TODO: Default settings speichern
        if(group.settings["ai_enabled"]) {
          if (group.settings["ai_interval"] != null) {
            if (group.lastAutomaticallyGenerated == null) {
              _createAutomaticList();
            } else {
              DateTime nextList = group.lastAutomaticallyGenerated.toDate().add(
                  Duration(days: group.settings["ai_interval"]));
              if (DateTime.now().isAfter(nextList)) {
                _createAutomaticList();
              }
            }
          }
        }
      }
      first = false;
    }
    List<ShoppingList> lists = Provider.of<List<ShoppingList>>(context);
    return lists != null ? lists.length == 0 ? Center(child: Text("Noch keine Einkaufslisten erstellt", style: Theme.of(context).textTheme.title,)) : ListView.separated(
        separatorBuilder: (ctx, i) => Divider(
          indent: 10,
          endIndent: 10,
          color: Colors.grey,
        ),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: lists.length,
        itemBuilder: (ctx, index) => w.ShoppingList(index: index, groupIndex: this.groupindex, isGroup: true)
    ) : ShoppyShimmer();
  }

  _createAutomaticList() async {
    final HttpsCallable autoList = cloudFunctionInstance.getHttpsCallable(
        functionName: "createAutomaticList"
    );
    try {
      dynamic resp = await autoList.call(<String, dynamic>{
        "groupid": _group.id
      });
      if (resp.data["status"] != "Successful") {
        //InfoOverlay.showErrorSnackBar("Fehler beim Erstellen der Automatischen Einkaufsliste");
      } else {
        InfoOverlay.showInfoSnackBar("Automatische Einkaufsliste wurde erstellt");
      }
    }catch(e) {
      InfoOverlay.showErrorSnackBar("Fehler: ${e.message}");
    }
  }
}


class ShoppingListsHistory extends StatelessWidget {
  final int groupindex;
  ShoppingListsHistory({this.groupindex});

  @override
  Widget build(BuildContext context) {
    List<CompletedShoppingList> lists = Provider.of<List<CompletedShoppingList>>(context);
    return lists != null ? lists.length == 0 ? Center(child: Text("Noch keine Einkäufe abgeschlossen", style: Theme.of(context).textTheme.title,)) : ListView.separated(
      separatorBuilder: (ctx, i) => Divider(
        indent: 10,
        endIndent: 10,
        color: Colors.grey,
      ),
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: lists.length,
      itemBuilder: (ctx, index) => w2.CompletedShoppingList(index: index, groupIndex: this.groupindex, isGroup: true)
    ) : ShoppyShimmer();
  }
}