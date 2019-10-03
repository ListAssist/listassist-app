import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listassist/models/User.dart';


class Group {
  final String title;
  final dynamic creator;
  final int memberCount;
  final List<dynamic> members;

  Group({this.title, this.creator, this.memberCount, this.members});

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Group(
        title: data["title"],
        creator: data["creator"],
        memberCount: data["memberCount"],
        members: data["members"]
    );
  }

  factory Group.fromMap(Map data) {
    data = data ?? { };
    print(data["members"]);
    return Group(
        title: data["title"],
        creator: data["creator"],
        memberCount: data["memberCount"],
        //TODO: Map array to User List
        members: data["members"]
    );
  }
}