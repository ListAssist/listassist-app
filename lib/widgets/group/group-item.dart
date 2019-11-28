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
    Group group = Provider.of<Group>(context);
    return group != null ?
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
              Provider<Group>.value(
                value: group,
                child: GroupDetail(index: index)),
              )
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(group.title, style: Theme.of(context).textTheme.title),
                  Text("${group.members.length} Mitglieder")
                ],
              ),
            ),
          ),
        )
    :
    //Nicht anzeigen falls z.B. eine ungültige ID angegeben wurde
    Container();
  }
}