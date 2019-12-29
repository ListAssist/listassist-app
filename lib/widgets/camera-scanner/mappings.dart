import 'package:listassist/models/Item.dart';
import 'package:listassist/models/PossibleItem.dart';
import 'package:listassist/services/recognize.dart';
import 'package:string_similarity/string_similarity.dart';

const double SORENSEN_THRESHOLD = 0.55;

int sortDistances(a, b) {
  /// TODO: Add third metric for matching
  double aEdit = a[0], bEdit = b[0];
  double aSorensen = a[1], bSorensen = b[1];

  if (aSorensen > bSorensen) {
    return -1;
  } else /** if (bSorensen >= aSorensen) **/ {
    return 1;
  }
}

Map<PossibleItem, List<Item>> getDetectedToShoppingSorted({List<PossibleItem> detectedItems, List<Item> shoppingItems}) {
  Map<PossibleItem, List<Item>> detectedToShopping = {};

  /// Calculate distances
  for (int i = 0; i < detectedItems.length; i++) {
    List<Item> distanceSortedItems = [];
    Map<Item, List<double>> itemToDistance = {};

    String name = detectedItems[i].name.join("");
    String trimmedDetect = name.replaceAll(" ", "");
    for (int j = 0; j < shoppingItems.length; j++) {
      String trimmedShopping = shoppingItems[j].name.replaceAll(" ", "");

      /// Get edit distance and check for a threshold if it's somewhere similar
      int editDistance = recognizeService.editDistance(trimmedDetect, trimmedShopping);
      double sorensenDiceDistance = StringSimilarity.compareTwoStrings(trimmedDetect.toLowerCase(), trimmedShopping.toLowerCase());

      print("Gotten $sorensenDiceDistance for comparing ${trimmedDetect.toLowerCase()} and ${trimmedShopping.toLowerCase()}");
      if (sorensenDiceDistance >= SORENSEN_THRESHOLD) {
        itemToDistance[shoppingItems[j]] = [editDistance.toDouble(), sorensenDiceDistance];
      }
    }

    /// Sort the map by the values (=distances)
    var sortedKeys = itemToDistance.keys.toList(growable:false)
      ..sort((Item a, Item b) => sortDistances(itemToDistance[a], itemToDistance[b]));
    distanceSortedItems = sortedKeys;

    /// set the value in Map
    detectedToShopping[detectedItems[i]] = distanceSortedItems;

    print("--------------------");
  }
  return detectedToShopping;
}

Map<Item, List<PossibleItem>> getShoppingToDetectedSorted({List<PossibleItem> detectedItems, List<Item> shoppingItems}) {
  Map<Item, List<PossibleItem>> shoppingToDetected = {};

  /// Calculate distances
  for (int i = 0; i < shoppingItems.length; i++) {
    List<PossibleItem> distanceSortedItems = [];
    Map<PossibleItem, List<double>> possibleItemToDistance = {};

    String trimmedShopping = shoppingItems[i].name.replaceAll(" ", "");
    for (int j = 0; j < detectedItems.length; j++) {
      String name = detectedItems[j].name.join("");
      String trimmedDetect = name.replaceAll(" ", "");

      /// Get edit distance and check if it's somewhere similar
      int editDistance = recognizeService.editDistance(trimmedDetect, trimmedShopping);
      double sorensenDiceDistance = StringSimilarity.compareTwoStrings(trimmedShopping.toLowerCase(), trimmedDetect.toLowerCase());

      if (sorensenDiceDistance >= SORENSEN_THRESHOLD) {
        possibleItemToDistance[detectedItems[j]] = [editDistance.toDouble(), sorensenDiceDistance];
      }
    }

    /// Sort the map by the values (=distances)
    var sortedKeys = possibleItemToDistance.keys.toList(growable:false)
      ..sort((PossibleItem a, PossibleItem b) => sortDistances(possibleItemToDistance[a], possibleItemToDistance[b]));

    distanceSortedItems = sortedKeys;

    /// set the value in Map
    shoppingToDetected[shoppingItems[i]] = distanceSortedItems;

    print("--------------------");
  }

  return shoppingToDetected;
}

Map<Item, PossibleItem> findMappings({List<PossibleItem> possibleItems, List<Item> shoppingItems}) {
  /// Check for matches in shopping list with Edit Distance
  /// TODO: Combine with other distance forms to optimize result
  /// Helper for mapping
  Map<Item, List<PossibleItem>> shoppingToDetected = getShoppingToDetectedSorted(detectedItems: possibleItems, shoppingItems: shoppingItems);
  Map<PossibleItem, List<Item>> detectedToShopping = getDetectedToShoppingSorted(detectedItems: possibleItems, shoppingItems: shoppingItems);
  Map<Item, PossibleItem> finalMappings = {};

  /// Mapping Detected Items to ShoppingList items
  int cycleTimeout = 0;
  while (possibleItems.isNotEmpty && cycleTimeout < shoppingItems.length * 2) {
    /// Get Mappings for item
    PossibleItem currentPossibleItem = possibleItems.removeAt(0);
    List<Item> prefsForItem = detectedToShopping[currentPossibleItem];

    for (Item item in prefsForItem) {
      if (!finalMappings.containsKey(item)) {
        /// Stur einfügen
        finalMappings[item] = currentPossibleItem;
        cycleTimeout = 0;
        break;
      } else {
        /// check if mapped item on object has bigger index than current item
        PossibleItem mappedItem = finalMappings[item];
        List<PossibleItem> prefsForShoppingItem = shoppingToDetected[item];
        if (prefsForShoppingItem.indexOf(currentPossibleItem) < prefsForShoppingItem.indexOf(mappedItem)) {
          finalMappings[item] = currentPossibleItem;
          possibleItems.add(mappedItem);
          cycleTimeout = 0;
          break;
        }
      }
    }
    cycleTimeout++;
  }
  return finalMappings;
}
