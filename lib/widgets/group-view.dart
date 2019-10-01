import 'package:flutter/material.dart';
import 'package:listassist/main.dart';
import 'package:listassist/widgets/group.dart';

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
          Group(title: "Kekos", memberCount: 7),
          Group(title: "Familie", memberCount: 4),
        ],
      ),
    );
  }
}