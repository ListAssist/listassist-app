import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/ShoppingList.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/widgets/group/edit_group.dart';
import 'package:listassist/widgets/group/group_userlist.dart';
import 'package:listassist/widgets/shoppinglist/shopping_list.dart' as w;
import 'package:provider/provider.dart';

class GroupDetail extends StatefulWidget {
  final index;
  GroupDetail({this.index});
  @override
  _GroupDetail createState() => _GroupDetail();
}
enum GroupAction { edit, leave, delete}

class _GroupDetail extends State<GroupDetail> {

  @override
  Widget build(BuildContext context) {
    Group group = Provider.of<List<Group>>(context)[widget.index];
    User user = Provider.of<User>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(group.title),
          actions: <Widget>[
            GroupMenu(uid: user.uid, group: group)
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list)),
              Tab(icon: Icon(Icons.insert_chart)),
              Tab(icon: Icon(Icons.group))
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamProvider<List<ShoppingList>>.value(
              value: databaseService.streamListsFromGroup(group.id),
              child: ShoppingLists(),
            ),
            Text("Statistiken der Gruppe"),
            GroupUserList(index: widget.index)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
              _showInviteDialog();
          },
          child: Icon(Icons.person_add),
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
            FlatButton(
              child: Text("Einladen"),
              onPressed: () {
                //TODO: Invite member with cloudfunction
                print(_addressController.text);
              },
            ),
          ],
        );
      },
    );
  }

}


class GroupMenu extends StatelessWidget {
  final Group group;
  final String uid;
  GroupMenu({this.uid, this.group});


  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<GroupAction>(
      onSelected: (GroupAction result) async {
        if(result == GroupAction.leave){
          try {
            final HttpsCallable leave = cloudFunctionInstance.getHttpsCallable(
                functionName: "leaveGroup"
            );
            dynamic resp = await leave.call(<String, dynamic>{
              "groupid": group.id
            });
            if (resp.data["status"] == "Failed") {
              InfoOverlay.showErrorSnackBar("Fehler beim Verlassen der Gruppe");
            } else {
              InfoOverlay.showInfoSnackBar("Gruppe verlassen");
              Navigator.pop(context);
            }
          }catch(e) {
            InfoOverlay.showErrorSnackBar("Fehler: ${e.message}");
          }
        }else if(result == GroupAction.edit) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Provider<Group>.value(
                  value: group,
                  child: EditGroup()),
            )
          );
        }else if(result == GroupAction.delete) {
          try {
            final HttpsCallable delete = cloudFunctionInstance.getHttpsCallable(
                functionName: "deleteGroup"
            );
            dynamic resp = await delete.call(<String, dynamic>{
              "groupid": group.id
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
          enabled: group.creator.uid == uid,
          child: Text('Gruppe bearbeiten'),
        ),
        PopupMenuItem<GroupAction>(
          value: GroupAction.delete,
          enabled: group.creator.uid == uid,
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

  @override
  Widget build(BuildContext context) {
    List<ShoppingList> lists = Provider.of<List<ShoppingList>>(context);
    print("BUILDING LISTS");
    return lists != null ? lists.length == 0 ? Center(child: Text("Noch keine Einkaufslisten erstellt", style: Theme.of(context).textTheme.title,)) : ListView.separated(
        separatorBuilder: (ctx, i) => Divider(
          indent: 10,
          endIndent: 10,
          color: Colors.grey,
        ),
        itemCount: lists.length,
        //TODO: Provider not found
        itemBuilder: (ctx, index) => w.ShoppingList(index: index)
    ) : SpinKitDoubleBounce(color: Colors.blueAccent,);
  }
}