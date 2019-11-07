import 'package:flutter/material.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/validators/email.dart';
import 'package:provider/provider.dart';
import 'settings-modal.dart';

class ProfileSettingsView extends StatefulWidget {
  @override
  _ProfileSettingsView createState() => _ProfileSettingsView();
}

class _ProfileSettingsView extends State<ProfileSettingsView> {
  SettingsModal modal = new SettingsModal();

  String _uid;
  String _displayName;
  String _email;

  String _newName;
  String _newEmail;

  bool _nameChanged = false;
  bool _emailChanged = false;


  // schaut ob der Name anders ist als der in der DB,
  // wenn ja dann wird der FOAB entsperrt
  _checkName(text) {
    if(_displayName != text) {
      setState(() {
        _nameChanged = true;
        _newName = text;
      });
    } else {
      setState(() {
        _nameChanged = false;
      });
    }
  }

  _checkEmail(text) {
    if(_email != text) {
      setState(() {
        _emailChanged = true;
        _newEmail = text;
      });
    } else {
      setState(() {
        _emailChanged = false;
      });
    }
  }

  _saveSettings() {
    if(_nameChanged) {
      databaseService.updateProfileName(_uid, _newName);
      _displayName = _newName;
      _nameChanged = false;
    }
    if(_emailChanged) {
      databaseService.updateEmail(_uid, _newEmail);
      _email = _newEmail;
      _emailChanged = false;
    }
  }

  @override
  Widget build(BuildContext context) {

    User user  = Provider.of<User>(context);
    _uid = user.uid;
    _displayName = user.displayName;
    _email = user.email;

    return Scaffold(
      //backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: Container(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            decoration: BoxDecoration(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: () => modal.mainBottomSheet(context),
                      child:
                        Hero(
                          tag: "profilePicture",
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(user.photoUrl),
                            radius: 50,
                          ),
                        )
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 50.0),

                    child: GestureDetector(
                        onTap: () => modal.mainBottomSheet(context),
                        child:
                      Text(
                        "Foto ändern",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        textAlign: TextAlign.center,
                      )
                    )
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child:
                      TextFormField(
                        initialValue: user.displayName,
                        onChanged: (text) {
                          _checkName(text);
                        },
                        decoration: InputDecoration(
                          labelText: 'Name',
                          icon: Icon(Icons.account_circle)
                        ),
                      ),
                  ),
                  TextFormField(
                    initialValue: user.email,
                    autovalidate: true,
                    onChanged: (text) {
                      _checkEmail(text);
                    },
                    decoration: InputDecoration(
                      labelText: 'E-Mail',
                      icon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: EmailValidator(),
                  ),


                ])
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: _nameChanged || _emailChanged ? (){ _saveSettings(); } : null,
          child: Icon(Icons.save),
          backgroundColor: _nameChanged || _emailChanged ? Colors.green : Colors.grey,
        ),
    );
  }
}