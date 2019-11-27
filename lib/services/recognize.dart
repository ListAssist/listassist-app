import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:listassist/models/Detection.dart';
import 'package:listassist/models/DetectionResponse.dart';

class RecognizeService {
  final String blackList = "%";
  final int minLength = 3;


  void processResponse(DetectionResponse response) {
    /// Split texts into array seperated by new lines
    List<String> lines = response.detectedString.split("\n");
    List<String> correctedLines = [];

    for (int i = 0; i < lines.length; i++) {
      /// Check if line is not empty and proceed
      if (lines[i].isNotEmpty) {
        List<String> lineSeperated = lines[i].split(" ");
        List<String> correctedLine = [];
        /// Iterate through line which has been splitted by a space
        for (int j = 0; j < lineSeperated.length; j++) {
          if (!_containsBlacklistedItem(lineSeperated[j]) && lineSeperated[j].length > minLength) {
            String finalPartString;
            if (double.tryParse(lineSeperated[j]) == null) {

            }
            correctedLine.add(finalPartString);
          }
        }
        correctedLines.add(correctedLine.join(" "));
      }
    }

    print(correctedLines.join("\n"));
  }

  bool _containsBlacklistedItem(String toCheck) {
    /// Check if char in string which is not allowed and delete part from line
    for (int i = 0; i < blackList.length; i++) {
      if (toCheck.contains(blackList[i])) {
        return true;
      }
    }
    return false;
  }
}

final RecognizeService recognizeService = RecognizeService();
