import 'package:cloud_firestore/cloud_firestore.dart';
import 'PublicUser.dart';


class Group {
  final String title;
  final PublicUser creator;
  final List<PublicUser> members;
  final String id;
  final Map settings;

  Group({this.title, this.creator, this.members, this.id, this.settings});

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data ?? { };

    return Group(
        id: doc.documentID,
        title: data["title"],
        creator: PublicUser.fromMap(data["creator"]),
        members: List.from(data["members"] ?? []).map((member) => PublicUser.fromMap(member)).toList(),
        settings: data["settings"] ?? {}
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
        members: List.from(data["members"] ?? []).map((member) => PublicUser.fromMap(member)).toList(),
        settings: data["settings"] ?? {}
    );
  }
}