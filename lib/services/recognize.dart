import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:listassist/models/Detection.dart';

class RecognizeService {
  final TextRecognizer _textRecognizer = FirebaseVision.instance.cloudTextRecognizer();

  Future<VisionText> recognizeTextFirebase(File imageAsFile) async {
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

  void processHTTPResponse(List<Detection> detections) {

  }

  void process() {

  }

}

final RecognizeService recognizeService = RecognizeService();