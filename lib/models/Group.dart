import 'package:cloud_firestore/cloud_firestore.dart';
import 'PublicUser.dart';


class Group {
  final String title;
  final PublicUser creator;
  final List<PublicUser> members;
  final String id;
  final Map settings;
  final Timestamp lastAutomaticallyGenerated;

  Group({this.title, this.creator, this.members, this.id, this.settings, this.lastAutomaticallyGenerated});

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data ?? { };

    return Group(
        id: doc.documentID,
        title: data["title"],
        creator: PublicUser.fromMap(data["creator"]),
        members: List.from(data["members"] ?? []).map((member) => PublicUser.fromMap(member)).toList(),
        lastAutomaticallyGenerated: data["last_automatically_generated"] ?? null,
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
        lastAutomaticallyGenerated: data["last_automatically_generated"] ?? null,
        settings: data["settings"] ?? {}
    );
  }
}