import 'package:flutter/material.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/widgets/group-userlist.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class GroupDetail extends StatefulWidget {
  final Group group;
  GroupDetail({this.group});

  @override
  _GroupDetail createState() => _GroupDetail(group: group);
}

class _GroupDetail extends State<GroupDetail> {

  final Group group;
  _GroupDetail({this.group});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Group>.value(
      value: databaseService.streamGroupsFromUser(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(group.title),
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
              GroupUserList()
            ],
          ),
        ),
      )
    );
  }
}