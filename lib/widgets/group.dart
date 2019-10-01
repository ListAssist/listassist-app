import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:listassist/widgets/group-detail.dart';
import 'package:listassist/widgets/shoppinglist-detail.dart';


class Group extends StatelessWidget {
  final String title;
  final int memberCount;
  Group({this.title = "Gruppe", this.memberCount = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupDetail(title: title)),
        ),
        child: Card(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.title),
                  Text("$memberCount Mitglieder")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}