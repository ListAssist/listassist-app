import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:listassist/models/CompletedShoppingList.dart' as model;
import 'package:listassist/services/date_formatter.dart';
import 'package:provider/provider.dart';
import 'completedshoppinglist-detail.dart';


class CompletedShoppingList extends StatelessWidget {
  final int index;
  CompletedShoppingList({this.index});

  @override
  Widget build(BuildContext context) {
    model.CompletedShoppingList list = Provider.of<List<model.CompletedShoppingList>>(context)[this.index];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Navigator.push(
        context,
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