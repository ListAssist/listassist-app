import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listassist/assets/custom_colors.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/PublicUser.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:provider/provider.dart';

class EditGroup extends StatefulWidget {
  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {

  TextEditingController _nameTextController;

  bool _firstLoad = true;
  List<PublicUser> _copyUsers;
  bool _aiEnabled;
  int _aiInterval;
  TextEditingController _intervalController;

  @override
  Widget build(BuildContext context) {
    Group group = Provider.of<Group>(context);
    if(_firstLoad) {
      _copyUsers = List.from(group.members);
      _aiEnabled = group.settings["ai_enabled"];
      _aiInterval = group.settings["ai_interval"] ?? 0;
      _intervalController = TextEditingController(text: "$_aiInterval");
      _nameTextController = TextEditingController(text: group.title);
      _firstLoad = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Gruppe bearbeiten"),
        backgroundColor: Provider.of<User>(context).settings["theme"] == "Blau" ? Theme.of(context).colorScheme.primary : CustomColors.shoppyGreen,
        flexibleSpace: Provider.of<User>(context).settings["theme"] == "Verlauf" ? Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: <Color>[
                      CustomColors.shoppyBlue,
                      CustomColors.shoppyLightBlue,
                    ])
            )) : Container(),),
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
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    CheckboxListTile(
                      title: Text("Automatische Einkaufsliste erstellen"),
                      value: _aiEnabled,
                      onChanged: (val) => setState(() => _aiEnabled = val),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    ListTile(
                      title: Text("Intervall"),
                      trailing: Container(
                        margin: EdgeInsets.only(right: 10),
                        width: 30,
                        child: TextField(
                          enabled: _aiEnabled,
                          keyboardType: TextInputType.number,
                          controller: _intervalController,
                          onChanged: (newValue) {
                            _aiInterval = int.parse(newValue);
                            print(_aiInterval);
                          },
                          style: TextStyle(
                              color: _aiEnabled ? Colors.black : Colors.grey
                          ),
                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],

                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _copyUsers.map<Widget>((i) {
                    return Container(
                      child: ListTile(
                        trailing: group.creator.uid != i.uid ? IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            setState(() {
                              _copyUsers.remove(i);
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
          final HttpsCallable update = cloudFunctionInstance.getHttpsCallable(
              functionName: "updateGroup"
          );
          try {
            dynamic resp = await update.call(<String, dynamic>{
              "group": {
                "title": _nameTextController.text,
                "id": group.id,
                "creator": group.creator.uid,
                "members": _copyUsers.map((user) => user.uid).toList(),
                "settings": {
                  "ai_enabled": _aiEnabled,
                  "ai_interval": _aiInterval
                }
              }
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
