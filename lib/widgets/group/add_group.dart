import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/achievements.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/validators/email.dart';

class AddGroup extends StatefulWidget {
  final User user;

  const AddGroup({this.user});

  @override
  _AddGroup createState() => _AddGroup();
}

class _AddGroup extends State<AddGroup> {

  final _memberTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> _members = [];

  bool _isCreating = false;

  _addMember(email) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    if(_members.contains(email)){
      InfoOverlay.showErrorSnackBar("User wird bereits eingeladen");
      setState(() {
        _memberTextController.clear();
      });
      return;
    }
    setState(() {
      _memberTextController.clear();
      _members.add(email);
    });
  }

  _createGroup() async {
    setState(() {
      _isCreating = true;
    });
    final HttpsCallable create = cloudFunctionInstance.getHttpsCallable(
        functionName: "createGroup"
    );
    try {
      dynamic resp = await create.call(<String, dynamic>{
        "title": _nameTextController.text,
      });
      if(resp.data["status"] == "Failed"){
        InfoOverlay.showErrorSnackBar("Fehler beim Erstellen der Gruppe");
      }else {
        InfoOverlay.showInfoSnackBar("Gruppe ${_nameTextController.text} erstellt");
        achievementsService.groupCreated(widget.user);
        if(_members.length == 0) {
          Navigator.pop(context);
          return;
        }
        final HttpsCallable invite = cloudFunctionInstance.getHttpsCallable(
            functionName: "inviteUsers"
        );
        try {
          dynamic resp2 = await invite.call(<String, dynamic>{
            "targetemails": _members,
            "groupid": resp.data["groupid"],
            "groupname": resp.data["groupname"],
            "from": resp.data["creator"],
          });
          if (resp2.data["status"] == "Failed") {
            InfoOverlay.showErrorSnackBar("Fehler beim Verschicken");
          } else {
            InfoOverlay.showInfoSnackBar("Einladungen verschickt");
            Navigator.pop(context);
          }
        }catch(e) {
          InfoOverlay.showErrorSnackBar("Fehler: ${e.message}");
        }
      }
    }catch (e) {
      InfoOverlay.showErrorSnackBar("Fehler: ${e.message}");
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameTextController.dispose();
    _memberTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Neue Gruppe erstellen"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: _nameTextController,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.all(3),
                labelText: 'Gruppenname',
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Gruppenmitglieder:"),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _memberTextController,
                          validator: EmailValidator(),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            contentPadding: EdgeInsets.all(3),
                            labelText: 'Email Adresse eingeben',
                          ),
                        ),
                      )
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _addMember(_memberTextController.text),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _members.map<Widget>((i) {
                      return Container(
                        child: ListTile(
                          trailing: IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                _members.remove(i);
                                print(_members);
                              });
                            }),
                          title: Text("$i"),
                        )
                      );
                    }).toList(),
                  ),
                )
              ],
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        backgroundColor: !_isCreating && _members != null && _members.isNotEmpty ? Colors.green : Colors.grey,
        onPressed: () => !_isCreating && _members != null && _members.isNotEmpty ? _createGroup() : null,
      ),
    );
  }

}