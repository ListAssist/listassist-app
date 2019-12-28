import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/main.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/widgets/group/add_group.dart';
import 'package:listassist/widgets/group/group_item.dart';
import 'package:provider/provider.dart';

class GroupView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<Group> groups = Provider.of<List<Group>>(context);
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
      body: groups != null ?
      ListView.separated(
        separatorBuilder: (ctx, i) => Divider(
          indent: 10,
          endIndent: 10,
          color: Colors.grey,
        ),
        itemCount: groups.length,
        itemBuilder: (BuildContext ctx, int index) => GroupItem(index: index)
      ) : SpinKitDoubleBounce(color: Colors.blueAccent),
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
