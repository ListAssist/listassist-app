import 'package:cloud_firestore/cloud_firestore.dart';


class Invite {
  final Timestamp created;
  final String from;
  final String groupname;

  Invite({this.from, this.created, this.groupname});

  factory Invite.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Invite(
        from: data["from"],
        created: data["created"],
        groupname: data["groupname"]
    );
  }

  factory Invite.fromMap(Map data) {
    data = data ?? { };
//    print(data);
    return Invite(
        from: data["from"],
        created: data["created"],
        groupname: data["groupname"]
    );
  }
}