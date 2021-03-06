import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement implements Comparable{
  final String name;
  final String description;
  final int points;

  Achievement({this.name, this.description, this.points});

  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Achievement(
      name: data["name"],
      description: data["description"],
      points: data["points"],
    );
  }

  factory Achievement.fromMap(Map data) {
    data = data ?? {};

    return Achievement(
      name: data["name"],
      description: data["description"],
      points: data["points"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'points': points,
    };
  }

  @override
  int compareTo(other) {
    if(this.points > other.points) {
      return -1;
    }

    if(this.points < other.points) {
      return 1;
    }

    if(this.points == other.points) {
      return this.name.compareTo(other.name);
    }
  }
}