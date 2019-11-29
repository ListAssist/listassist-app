import 'package:listassist/models/Detection.dart';

class DetectionResponse {
  List<Detection> detections;
  String detectedString;

  DetectionResponse({this.detections, this.detectedString});


  DetectionResponse.fromJson(Map<String, dynamic> json) {
    detections = Detection.multipleFromJson(json["detections"]);
    detectedString = json["detected_string"];
  }
}
