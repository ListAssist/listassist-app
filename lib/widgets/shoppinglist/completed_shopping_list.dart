import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:listassist/models/CompletedShoppingList.dart' as model;
import 'package:listassist/models/Group.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/date_formatter.dart';
import 'package:listassist/services/db.dart';
import 'package:provider/provider.dart';
import 'completed_shopping_list_detail.dart';


class CompletedShoppingList extends StatelessWidget {
  final int index;
  final bool isGroup;
  final int groupIndex;
  CompletedShoppingList({this.index, this.isGroup = false, this.groupIndex = 0});

  String groupid;

  @override
  Widget build(BuildContext context) {
    model.CompletedShoppingList list = Provider.of<List<model.CompletedShoppingList>>(context)[this.index];
    if(this.isGroup) {
       groupid = Provider.of<List<Group>>(context)[this.groupIndex].id;
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Navigator.push(
        context,
        this.isGroup ?
        MaterialPageRoute(builder: (context) {
          return StreamProvider<model.CompletedShoppingList>.value(
              value: databaseService.streamCompletedListFromGroup(groupid, list.id),
              child: CompletedShoppingListDetail(index: this.groupIndex, isGroup: true)
          );
        }) :
        MaterialPageRoute(builder: (context) => CompletedShoppingListDetail(index: this.index)),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(list.name, style: Theme.of(context).textTheme.title),
              Text("Erledigt am ${DateFormatter.getDate(list.completed.toDate())}")
            ],
          ),
        ),
      )
    );
  }
}