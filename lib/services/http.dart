import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:listassist/models/Detection.dart';

class HttpService {
  /// adb reverse tcp:5000 tcp:5000
  final Dio _dio = Dio()
    ..options.baseUrl = "http://127.0.0.1:5000/";

  /// Send coordinates of box to api to evaluate image
  Future<List<Detection>> getDetections(File imageFile, List<Map<String, double>> exportedPoints) async {
    FormData formData = new FormData.fromMap({
      "bill": await MultipartFile.fromFile(imageFile.path),
      "coordinates": jsonEncode(exportedPoints)
    });

    Response<Map> response = await _dio.post("/", data: formData, options: Options(responseType: ResponseType.json));
    List<Detection> detections = Detection.multipleFromJson(response.data["detections"]);
    return detections;
  }

}
final HttpService httpService = HttpService();