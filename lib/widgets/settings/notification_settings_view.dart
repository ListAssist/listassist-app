import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:provider/provider.dart';

class Keko extends StatefulWidget{
  NotificationsettingsView createState()=> NotificationsettingsView();
}

class NotificationsettingsView extends State<Keko> {

  User _user;
  Map _settings;

  bool _initialized = false;

  Timer _debounce;
  int _debounceTime = 2000;

  void requestSettingsUpdate() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debounceTime), () {
      databaseService.updateUserSettings(_user.uid, _settings);
    });
  }

  Future initializeSettings () async {
    _settings = await databaseService.getUserSettings(_user.uid);
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);
    _initialized ? null : initializeSettings();

    return Scaffold(
      //backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: _initialized ? Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            decoration: BoxDecoration(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: <Widget>[
                        SwitchListTile(
                          title: const Text('Benachrichtigungen'),
                          value: _settings["msg_general"],
                          onChanged: (bool value) {
                            setState(() {
                              _settings["msg_general"] = value;
                            });
                            requestSettingsUpdate();
                          },
                          secondary: const Icon(Icons.notifications),
                        ),
                        Divider(),

                        SwitchListTile(
                          title: const Text('Gruppeneinladungen'),
                          value: _settings["msg_invite"] && _settings["msg_general"],
                          onChanged: _settings["msg_general"] ? (bool value) {
                            setState(() {
                              _settings["msg_invite"] = value;
                            });
                            requestSettingsUpdate();
                          } : null,
                          secondary: const Icon(Icons.mail),
                        ),

                        SwitchListTile(
                          title: const Text('Automatische Einkaufsliste'),
                          value: _settings["msg_autolist"] && _settings["msg_general"],
                          onChanged: _settings["msg_general"] ? (bool value) {
                            setState(() {
                              _settings["msg_autolist"] = value;
                            });
                            requestSettingsUpdate();
                          } : null,
                          secondary: const Icon(Icons.autorenew),
                        ),

                        SwitchListTile(
                          title: const Text('Angebote'),
                          value: _settings["msg_offer"] && _settings["msg_general"],
                          onChanged: _settings["msg_general"] ? (bool value) {
                            setState(() {
                              _settings["msg_offer"] = value;
                            });
                            requestSettingsUpdate();
                          } : null,
                          secondary: const Icon(Icons.local_offer),
                        ),


                      ]
                  )
                ])
        ) : ShoppyShimmer()
    );
  }
}