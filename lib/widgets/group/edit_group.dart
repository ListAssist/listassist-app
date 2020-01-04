import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/PublicUser.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:provider/provider.dart';

class EditGroup extends StatefulWidget {
  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {

  TextEditingController _nameTextController;

  bool firstLoad = true;
  List<PublicUser> copyUsers;

  @override
  Widget build(BuildContext context) {
    Group group = Provider.of<Group>(context);
    if(firstLoad) {
      copyUsers = List.from(group.members);
      _nameTextController = TextEditingController(text: group.title);
      firstLoad = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Gruppe bearbeiten"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    controller: _nameTextController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      contentPadding: EdgeInsets.all(3),
                      labelText: "Name der Gruppe",
                    ),
                  )
              ),
              Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: copyUsers.map<Widget>((i) {
                    return Container(
                      child: ListTile(
                        trailing: group.creator.uid != i.uid ? IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            setState(() {
                              copyUsers.remove(i);
                            });
                          }) : null,
                        title: new Text("${i.displayName}"),
                      )
                    );
                  }).toList(),
                ),
              )
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
          //TODO: create update cloud function to remove removed members and invite newly added ones
          final HttpsCallable update = cloudFunctionInstance.getHttpsCallable(
              functionName: "updateGroup"
          );
          try {
            dynamic resp = await update.call(<String, dynamic>{
              "group": { "title": _nameTextController.text, "id": group.id, "creator": group.creator.uid, "members": copyUsers.map((user) => user.uid).toList() }
            });
            if(resp.data["status"] != "Successful"){
              InfoOverlay.showErrorSnackBar("Fehler beim Bearbeiten der Gruppe");
            }else {
              InfoOverlay.showInfoSnackBar("Gruppe ${group.title} bearbeitet");
              Navigator.pop(context);
            }
          }catch (e) {
            print(e);
            InfoOverlay.showErrorSnackBar("Fehler: ${e.message}");
          }
        },
      ),
    );
  }
}
