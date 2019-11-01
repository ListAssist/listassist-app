import 'package:cloud_firestore/cloud_firestore.dart';

class Invite {
  final String id;
  final Timestamp created;
  final String from;
  final String groupname;
  final String groupid;

  Invite({this.id, this.from, this.created, this.groupname, this.groupid});

  factory Invite.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Invite(
        id: doc.documentID,
        from: data["from"],
        created: data["created"],
        groupname: data["groupname"],
        groupid: data["groupid"],
    );
  }

  factory Invite.fromMap(Map data) {
    data = data ?? { };

    return Invite(
        from: data["from"],
        created: data["created"],
        groupname: data["groupname"],
        groupid: data["groupid"]
    );
  }
}