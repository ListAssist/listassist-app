import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final Timestamp time;
  final String url;

  Bill({this.time, this.url});

  factory Bill.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data ?? { };

    return Bill(
        time: data["time"],
        url: data["url"]
    );
  }

  factory Bill.fromMap(Map data) {
    if(data == null)
      return null;
    data = data ?? { };

    return Bill(
        time: data["time"],
        url: data["url"]
    );
  }
}