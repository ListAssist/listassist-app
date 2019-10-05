import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:listassist/services/auth.dart';

class RecognizeService {
  final TextRecognizer _textRecognizer = FirebaseVision.instance.cloudTextRecognizer();

  Future<List<dynamic>> recognizeText(File imageAsFile) async {
    print("Remove 'return' keyword to use FirebaseMLVIsion");
    return null;
    VisionText text = await _textRecognizer.processImage(FirebaseVisionImage.fromFile(imageAsFile));
    for (TextBlock block in text.blocks) {
      for (TextLine line in block.lines) {
        var text = line.text;
        var confidence = line.confidence;
        String languages = line.recognizedLanguages.map((value) => value.languageCode).join("|");

        print("text: $text");
        print("confidence: $confidence");
        print("languages: $languages");
      }
      print("----------------------------------");
      print("NEXT BLOCK");
      print("----------------------------------");
    }
  }

}

final RecognizeService recognizeService = RecognizeService();