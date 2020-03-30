import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listassist/models/Achievement.dart';


class User {
  final String email;
  final String displayName;
  final String photoUrl;
  final String uid;
  final String type;
  final Map settings;
  final Timestamp lastAutomaticallyGenerated;
  final Timestamp lastLogin;
  Map stats;
  List<Achievement> achievements;
  bool hasUnlockedAchievements;

  User({this.lastLogin, this.email, this.displayName, this.photoUrl, this.uid, this.type, this.settings, this.lastAutomaticallyGenerated, this.stats, this.achievements, this.hasUnlockedAchievements});

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return User(
      uid: data["uid"],
      email: data["email"],
      photoUrl: data["photoURL"] ?? "",
      displayName: data["displayName"] ?? '',
      lastLogin: data["lastLogin"] ?? null,
      type: data["type"] ?? null,
      settings: data["settings"] ?? {
        "ai_enabled": true,
        "ai_interval": 5,
        "msg_autolist": false,
        "msg_general": false,
        "msg_invite": false,
        "msg_offer": false,
        "scanner_manual": true,
        "theme": "Verlauf",
      },
      lastAutomaticallyGenerated: data["last_automatically_generated"] ?? null,
      stats: data["stats"] ?? {},
      achievements: List.from(data["achievements"] ?? []).map((a) => Achievement.fromMap(a)).toList(),
      hasUnlockedAchievements: data["hasUnlockedAchievements"] ?? false,
    );
  }

  factory User.fromMap(Map data) {
    data = data ?? { };
    print(data);
    print(data["settings"].runtimeType);
    return User(
      uid: data["uid"],
      email: data["email"],
      photoUrl: data["photoURL"] ?? "",
      displayName: data["displayName"] ?? "",
      lastLogin: data["lastLogin"] ?? null,
      type: data["type"] ?? null,
      settings: data["settings"] ?? {
        "ai_enabled": true,
        "ai_interval": 5,
        "msg_autolist": false,
        "msg_general": false,
        "msg_invite": false,
        "msg_offer": false,
        "scanner_manual": true,
        "theme": "Verlauf",
      },
      lastAutomaticallyGenerated: data["last_automatically_generated"] ?? null,
      stats: data["stats"] ?? {},
      achievements: List.from(data["achievements"] ?? []).map((a) => Achievement.fromMap(a)).toList(),
      hasUnlockedAchievements: data["hasUnlockedAchievements"] ?? false,
    );
  }
}