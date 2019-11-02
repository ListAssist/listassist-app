import 'package:cloud_firestore/cloud_firestore.dart';
import 'PublicUser.dart';


class Group {
  final String title;
  final PublicUser creator;
  final int memberCount;
  final List<PublicUser> members;

  Group({this.title, this.creator, this.memberCount, this.members});

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data ?? { };

    return Group(
        title: data["title"],
        creator: PublicUser.fromMap(data["creator"]),
        members: List.from(data["members"] ?? []).map((member) => PublicUser.fromMap(member)).toList()
    );
  }

  factory Group.fromMap(Map data) {
    if(data == null)
      return null;
    data = data ?? { };
//    print(data["members"]);
    return Group(
        title: data["title"],
        creator: PublicUser.fromMap(data["creator"]),
        members: List.from(data["members"] ?? []).map((member) => PublicUser.fromMap(member)).toList()
    );
  }
}