class Detection {
  int x;
  int y;
  int width;
  int height;
  String text;
  double confidence;

  Detection(
      {this.x, this.y, this.width, this.height, this.text, this.confidence});

  Detection.fromJson(Map<String, dynamic> json) {
    x = json["x"];
    y = json["y"];
    width = json["width"];
    height = json["height"];
    text = json["text"];
    confidence = json["confidence"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["x"] = this.x;
    data["y"] = this.y;
    data["width"] = this.width;
    data["height"] = this.height;
    data["text"] = this.text;
    data["confidence"] = this.confidence;
    return data;
  }

  static multipleFromJson(List<dynamic> jsonArray) {
    List<Detection> detections = [];
    jsonArray.forEach((detectionJson) {
      detections.add(Detection.fromJson(detectionJson));
    });

    return detections;
  }
}