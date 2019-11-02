import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:listassist/models/Group.dart';
import 'package:provider/provider.dart';


class GroupUserList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Group group = Provider.of<Group>(context);

    List<Widget> members = group.members.map((member) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              CircleAvatar(backgroundImage: NetworkImage(member.photoUrl)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Text(
                    member.displayName,
                    style: Theme.of(context).textTheme.subhead,
                    overflow: TextOverflow.ellipsis
                  ),
                )
              ),
            ],
          )
        ),
      );
    }).toList();

    members.insert(0, Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              CircleAvatar(backgroundImage: NetworkImage(group.creator.photoUrl)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Text(
                    group.creator.displayName,
                    style: Theme.of(context).textTheme.subhead,
                    overflow: TextOverflow.ellipsis
                  ),
                )
              ),
              Text("Gruppenersteller", style: TextStyle(color: Colors.green))
            ],
          )
      ),
    ));

    return ListView(
      children: members,
    );
  }
}


/*
ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey,
          endIndent: 10,
          indent: 10,
        ),
        itemCount: members.length,
        itemBuilder: (context, index) => members[index]
    );
 */