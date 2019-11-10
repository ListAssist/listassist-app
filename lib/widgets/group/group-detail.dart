import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/snackbar.dart';
import 'package:listassist/widgets/group/group-userlist.dart';
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
    //FIXME: Provider not found
    Group group = Provider.of<Group>(context);
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
            Text("Einkaufslisten der Gruppe"),
            Text("Statistiken der Gruppe"),
            GroupUserList()
          ],
        ),
      ),
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
            final HttpsCallable leave = CloudFunctions.instance.getHttpsCallable(
                functionName: "leaveGroup"
            );
            dynamic resp = await leave.call(<String, dynamic>{
              "groupid": group.id
            });
            if (resp.data["status"] == "Failed") {
              InfoSnackbar.showErrorSnackBar("Fehler beim Verlassen der Gruppe");
            } else {
              InfoSnackbar.showInfoSnackBar("Gruppe verlassen");
              Navigator.pop(context);
            }
          }catch(e) {
            InfoSnackbar.showErrorSnackBar("Fehler: ${e.message}");
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