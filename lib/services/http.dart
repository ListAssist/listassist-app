import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:listassist/models/Detection.dart';

class HttpService {
  /// adb reverse tcp:5000 tcp:5000
  final Dio _dio = Dio()
    ..options.baseUrl = "http://127.0.0.1:5000/";

  /// Send coordinates of box to api to evaluate image
  Future<List<Detection>> getDetectionWithCoords(File imageFile, List<Map<String, double>> exportedPoints, {Function onProgress}) async {
    FormData formData = FormData.fromMap({
      "bill": await MultipartFile.fromFile(imageFile.path),
      "coordinates": jsonEncode(exportedPoints)
    });

    Response<Map> response = await _dio.post("/trainable", data: formData, onSendProgress: onProgress, options: Options(responseType: ResponseType.json));
    return Detection.multipleFromJson(response.data["detections"]);
  }

  Future<List<Detection>> getDetection(File imageFile, { Function onProgress }) async {
    FormData formData = FormData.fromMap({
      "bill": await MultipartFile.fromFile(imageFile.path),
    });
    Response<Map> response = await _dio.post("/prediction", data: formData, onSendProgress: onProgress, options: Options(responseType: ResponseType.json));
    return Detection.multipleFromJson(response.data["detections"]);
  }
}
final HttpService httpService = HttpService();