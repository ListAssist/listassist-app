import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:provider/provider.dart';

class AppSettingsView extends StatefulWidget{
  AppSettingsViewState createState()=> AppSettingsViewState();
}

class AppSettingsViewState extends State<AppSettingsView> {

  User _user;
  Map _settings;

  bool _initialized = false;

  Timer _debounce;
  int _debounceTime = 2000;

  String _themeValue = "Light";
  String _cameraScannerValue;

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
        body:
          _initialized ? ListView(
            padding: EdgeInsets.only(top: 15),
            children: <Widget>[
              Container(
                child: Center(
                  child: Text(
                    "Theme",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                color: Colors.black12,
                height: 32,
              ),
              ListTile(
                contentPadding: EdgeInsets.only(left: 20, top: 0, right: 35),
                leading: Icon(Icons.aspect_ratio),
                title: Text("Theme"),
                trailing: DropdownButton<String>(
                  value: _themeValue,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  onChanged: (String newValue) {
                    setState(() {
                      _themeValue = newValue;
                    });
                  },
                  items: <String>['Light', 'Dark']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 16),),
                    );
                  })
                      .toList(),
                ),
              ),
              Container(
                child: Center(
                  child: Text(
                    "Camera Scanner",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                color: Colors.black12,
                height: 32,
              ),
              ListTile(
                contentPadding: EdgeInsets.only(left: 20, top: 0, right: 35),
                leading: Icon(Icons.camera),
                title: Text("Scanner"),
                trailing: DropdownButton<String>(
                  value: _settings["scanner_manual"] ? "Manuell" : "Automatisch",
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  onChanged: (String newValue) {
                    setState(() {
                      newValue == "Manuell" ? _settings["scanner_manual"] = true : _settings["scanner_manual"] = false;
                    });
                    requestSettingsUpdate();
                  },
                  items: <String>['Manuell', 'Automatisch']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 16),),
                    );
                  })
                      .toList(),
                ),
              ),
            ]
          ) : ShoppyShimmer()

    );
  }
}