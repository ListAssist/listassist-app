import 'package:listassist/models/Achievement.dart';
import 'package:listassist/models/Item.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/db.dart';

class AchievementsService {

  Map<String, Achievement> achievements = {
    "einkaufslisten1": new Achievement(name: "Einkaufslisten I", description: "Erstelle 10 Einkaufslisten", points: 10),
    "einkaufslisten2" : new Achievement(name: "Einkaufslisten II", description: "Erstelle 50 Einkaufslisten", points: 50),
    "einkaufslisten3" : new Achievement(name: "Einkaufslisten III", description: "Erstelle 100 Einkaufslisten", points: 100),
    "rezepte1" : new Achievement(name: "Rezepte I", description: "Erstelle ein Rezept", points: 10),
    "rezepte2" : new Achievement(name: "Rezepte II", description: "Erstelle 10 Rezepte", points: 50),
    "rezepte3" : new Achievement(name: "Rezepte III", description: "Erstelle 25 Rezepte", points: 100),
    "gruppenersteller" : new Achievement(name: "Gruppenersteller", description: "Erstelle eine Gruppe", points: 10),
    "grosseinkaeufer1" : new Achievement(name: "Großeinkäufer I", description: "Schließe eine Einkaufsliste ab, die mindestens 25 verschiedene, gekaufte Produkte enthält", points: 10),
    "grosseinkaeufer2" : new Achievement(name: "Großeinkäufer II", description: "Schließe eine Einkaufsliste ab, die mindestens 50 verschiedene, gekaufte Produkte enthält", points: 25),
    "grosseinkaeufer3" : new Achievement(name: "Großeinkäufer III", description: "Schließe eine Einkaufsliste ab, die mindestens 100 verschiedene, gekaufte Produkte enthält ", points: 50),
    "kekachievement" : new Achievement(name: "Kek", description: "Erstelle eine Einkaufsliste, die Kek heißt", points: 10),
    "teurerspass1" : new Achievement(name: "Teurer Spaß I", description: "Schließe eine Einkaufsliste ab, die Produkte im Wert von mindestens 50€ enthält", points: 25),
    "teurerspass2" : new Achievement(name: "Teurer Spaß II", description: "Schließe eine Einkaufsliste ab, die Produkte im Wert von mindestens 100€ enthält", points: 50),
    "teurerspass3" : new Achievement(name: "Teurer Spaß III", description: "Schließe eine Einkaufsliste ab, die Produkte im Wert von mindestens 250€ enthält", points: 100),
    "scanner1" : new Achievement(name: "Scanner I", description: "Scanne eine Rechnung"),
    "scanner2" : new Achievement(name: "Scanner II", description: "Scanne 5 Rechnungen"),
    "scanner3" : new Achievement(name: "Scanner III", description: "Scanne 25 Rechnungen"),
  };

  listCreated(User user) {
    if (user.stats["lists_created"] != null) {
      user.stats["lists_created"] += 1;
      switch (user.stats["lists_created"]) {
        case 10:
          {
            databaseService.addAchievement(user.uid, achievements["einkaufslisten1"]);
          }
          break;

        case 50:
          {
            databaseService.addAchievement(user.uid, achievements["einkaufslisten2"]);
          }
          break;

        case 100:
          {
            databaseService.addAchievement(user.uid, achievements["einkaufslisten3"]);
          }
          break;
      }
    } else {
      user.stats["lists_created"] = 1;
    }
    databaseService.updateUserStats(user.uid, user.stats);
  }

  recipeCreated(User user) {
    if (user.stats["recipes_created"] != null) {
      user.stats["recipes_created"] += 1;
      switch (user.stats["lists_created"]) {
        case 10:
          {
            databaseService.addAchievement(user.uid, achievements["rezepte2"]);
          }
          break;

        case 25:
          {
            databaseService.addAchievement(user.uid, achievements["rezepte3"]);
          }
          break;
      }
    } else {
      user.stats["recipes_created"] = 1;
      databaseService.addAchievement(user.uid, achievements["rezepte1"]);
    }
    databaseService.updateUserStats(user.uid, user.stats);
  }

  groupCreated(User user) {
    if (user.stats["groups_created"] != null) {
      user.stats["groups_created"] += 1;
    } else {
      user.stats["groups_created"] = 1;
      databaseService.addAchievement(user.uid, achievements["gruppenersteller"]);
    }
    databaseService.updateUserStats(user.uid, user.stats);
  }

  cameraScanned(User user) {
    //TODO implement pls
  }

  checkListName(User user, String name) {
    print(!user.achievements.contains(achievements["kekachievement"]));
    if (!user.achievements.contains(achievements["kekachievement"]) && name.toUpperCase() == "KEK") {
      databaseService.addAchievement(user.uid, achievements["kekachievement"]);
    }
  }

  checkListItems(User user, List<Item> items) {
    if (items.length >= 25 && !user.achievements.contains(achievements["grosseinkaeufer1"])) {
      databaseService.addAchievement(user.uid, achievements["grosseinkaeufer1"]);
    }
    if (items.length >= 50 && !user.achievements.contains(achievements["grosseinkaeufer2"])) {
      databaseService.addAchievement(user.uid, achievements["grosseinkaeufer2"]);
    }
    if (items.length >= 100 && !user.achievements.contains(achievements["grosseinkaeufer3"])) {
      databaseService.addAchievement(user.uid, achievements["grosseinkaeufer3"]);
    }
  }

  checkListPrice(User user, List<Item> items) {
    double price = 0;
    items.forEach((i) => price += i.price);

    if (price >= 50 && !user.achievements.contains(achievements["teurerspass1"])) databaseService.addAchievement(user.uid, achievements["teurerspass1"]);
    if (price >= 100 && !user.achievements.contains(achievements["teurerspass2"])) databaseService.addAchievement(user.uid, achievements["teurerspass2"]);
    if (price >= 250 && !user.achievements.contains(achievements["teurerspass3"])) databaseService.addAchievement(user.uid, achievements["teurerspass3"]);
  }

//TODO: Die restlichen Achievements noch einbauen
}

final AchievementsService achievementsService = AchievementsService();