import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/main.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/add-group.dart';
import 'package:listassist/widgets/group-item.dart';

class GroupView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Gruppen"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: "Open navigation menu",
          onPressed: () => mainScaffoldKey.currentState.openDrawer(),
        ),
      ),
      body: ListView(
        children: <Widget>[
          GroupItem(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: "Neue Gruppe erstellen",
        onPressed: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddGroup()),
          )
      ),
    );
  }
}
