import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/main.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/widgets/group/add-group.dart';
import 'package:listassist/widgets/group/group-item.dart';
import 'package:provider/provider.dart';

class GroupView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<Stream<Group>> groups = Provider.of<List<Stream<Group>>>(context);
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
      ListView.builder(
        itemCount: groups.length,
        itemBuilder: (BuildContext ctx, int index) =>
          StreamProvider<Group>.value(
              value: groups[index],
              child: GroupItem(index: index),
          )
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
