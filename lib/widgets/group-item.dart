import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/models/Group.dart';
import 'package:listassist/widgets/group-detail.dart';
import 'package:provider/provider.dart';


class GroupItem extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Group group = Provider.of<Group>(context);
    return group != null ?
      Container(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
//              return Provider<Group>.value(
//                value: group,
//                child: GroupDetail()
//              );
              return GroupDetail();
            }),
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
    SpinKitDoubleBounce(color: Colors.blueAccent);
  }
}