import 'package:flutter/material.dart';

import '../main.dart';

class GroupDetail extends StatefulWidget {
  final String title;
  GroupDetail({this.title = "Gruppe"});

  @override
  _GroupDetail createState() => _GroupDetail(title: title);
}

class _GroupDetail extends State<GroupDetail> {

  String title;
  _GroupDetail({this.title: "Gruppe"});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(this.title),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.list)),
                Tab(icon: Icon(Icons.insert_chart)),
                Tab(icon: Icon(Icons.group))
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Text("Einkaufslisten der Gruppe"),
              Text("Statistiken der Gruppe"),
              Text("Mitglieder der Gruppe")
            ],
          ),
        )
    );
  }
}