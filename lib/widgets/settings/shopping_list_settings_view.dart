import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ShoppinglistsettingsView extends StatefulWidget{
  ShoppinglistsettingsViewState createState()=> ShoppinglistsettingsViewState();
}

class ShoppinglistsettingsViewState extends State<ShoppinglistsettingsView> {

  String themeValue = "Light";
  String cameraScannerValue = "Manuell";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body:
          ListView(
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
                  value: themeValue,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  onChanged: (String newValue) {
                    setState(() {
                      themeValue = newValue;
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
                  value: cameraScannerValue,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  onChanged: (String newValue) {
                    setState(() {
                      cameraScannerValue = newValue;
                    });
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
          )

    );
  }
}