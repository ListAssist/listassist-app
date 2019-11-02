import 'package:flutter/material.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/widgets/group/group-userlist.dart';
import 'package:provider/provider.dart';

class GroupDetail extends StatefulWidget {
  @override
  _GroupDetail createState() => _GroupDetail();
}

class _GroupDetail extends State<GroupDetail> {

  @override
  Widget build(BuildContext context) {
    //FIXME: Provider not found
    Group group = Provider.of<Group>(context);
    return DefaultTabController(
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
    );
  }
}