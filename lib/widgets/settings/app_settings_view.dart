import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/shimmer/shoppy_shimmer.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class AppSettingsView extends StatefulWidget{
  AppSettingsViewState createState()=> AppSettingsViewState();
}

class AppSettingsViewState extends State<AppSettingsView> {

  User _user;
  Map _settings;

  bool _initialized = false;

  String _intervalType = "Tage";
  TextEditingController _intervalController = new TextEditingController();

  Timer _debounce;
  int _debounceTime = 2000;

  String _themeValue = "Light";

  void requestSettingsUpdate() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debounceTime), () {
      _settings["ai_interval"] = _intervalType == "Wochen" ? int.parse(_intervalController.text)*7 : int.parse(_intervalController.text);
      databaseService.updateUserSettings(_user.uid, _settings);
      print("updated settings");
    });
  }

  Future initializeSettings () async {
    _settings = await databaseService.getUserSettings(_user.uid);
    setState(() {
      _initialized = true;
    });

    if(_settings["ai_interval"] != null) {
      _intervalController.text = _settings["ai_interval"].toString();
      if(_settings["ai_interval"] % 7 == 0) {
        _intervalController.text = (_settings["ai_interval"]/7).round().toString();
        _intervalType = "Wochen";
        setState(() {
        });
      }
    }
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
                      _settings["scanner_manual"] = newValue == "Manuell";
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
              Container(
                child: Center(
                  child: Text(
                    "Automatische Einkaufsliste",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                color: Colors.black12,
                height: 32,
              ),
              ListTile(
                contentPadding: EdgeInsets.only(left: 20, top: 0, right: 35),
                leading: Icon(Icons.format_list_numbered),
                title: Text("Vorschläge"),
                trailing: DropdownButton<String>(
                  value: _settings["ai_enabled"] ? "Aktiviert" : "Deaktiviert",
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  onChanged: (String newValue) {
                    setState(() {
                      _settings["ai_enabled"] = newValue == "Aktiviert";
                    });
                    requestSettingsUpdate();
                  },
                  items: <String>['Aktiviert', 'Deaktiviert']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 16),),
                    );
                  })
                      .toList(),
                ),
              ),
              ListTile(
                enabled: _settings["ai_enabled"],
                contentPadding: EdgeInsets.only(left: 20, top: 0, right: 35),
                leading: Icon(Icons.repeat),
                title: Text("Intervall"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 30,
                      child: TextField(
                        enabled: _settings["ai_enabled"],
                        keyboardType: TextInputType.number,
                        controller: _intervalController,
                        onChanged: (newValue) {
                          _settings["ai_interval"] = int.parse(_intervalController.text);
                          requestSettingsUpdate();
                        },
                        style: TextStyle(
                          color: _settings["ai_enabled"] ? Colors.black : Colors.grey
                        ),
                        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 5, top: 8),
                        ),
                      ),
                    ),

                    DropdownButton<String>(
                      value: _intervalType,
                      disabledHint: Text(_intervalType),
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      onChanged: _settings["ai_enabled"] ? (String newValue) {
                        setState(() {
                          _intervalType = newValue;
                        });
                        requestSettingsUpdate();
                      } : null,
                      items: <String>['Tage', 'Wochen']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 16),),
                        );
                      })
                          .toList(),
                    ),
                  ],
                ),
              ),
            ]
          ) : ShoppyShimmer()

    );
  }
}