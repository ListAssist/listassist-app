import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/widgets/group/group-detail.dart';
import 'package:provider/provider.dart';


class GroupItem extends StatelessWidget {
  final index;
  GroupItem({this.index});

  @override
  Widget build(BuildContext context) {
    Group group = Provider.of<List<Group>>(context)[index];
    return group != null ?
      Container(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GroupDetail(index: index)),
          ),
          child: Card(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(group.title, style: Theme.of(context).textTheme.title),
                    Text("${group.members.length + 1} Mitglieder")
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    :
    //Nicht anzeigen falls z.B. eine ungültige ID angegeben wurde
    Container();
  }
}