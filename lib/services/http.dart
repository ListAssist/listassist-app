import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:listassist/models/DetectionResponse.dart';

class HttpService {
  /// adb reverse tcp:5000 tcp:5000
  final Dio _dio = Dio()
    ..options.baseUrl = "http://127.0.0.1:5000/";

  /// Send coordinates of box to api to evaluate image
  Future<DetectionResponse> getDetectionWithCoords(File imageFile, List<Map<String, double>> exportedPoints, {Function onProgress}) async {
    FormData formData = await _generateForm(imageFile, jsonEncode(exportedPoints));

    return _postToAPI("/trainable", formData, onProgress);
  }

  Future<DetectionResponse> getAutoDetection(File imageFile, { Function onProgress }) async {
    FormData formData = await _generateForm(imageFile);
    return _postToAPI("/prediction", formData, onProgress);
  }

  Future<DetectionResponse> getDetection(File imageFile, { Function onProgress }) async {
    FormData formData = await _generateForm(imageFile);
    return _postToAPI("/detect", formData, onProgress);
  }


  /// Helper Functions
  Future<DetectionResponse> _postToAPI(String endpoint, FormData form, Function progressFunction) async {
    Response<Map> response = await _dio.post(endpoint, data: form, onSendProgress: progressFunction, options: Options(responseType: ResponseType.json));
    return DetectionResponse.fromJson(response.data);
  }

  Future<FormData> _generateForm(File billFile, [String points]) async {
    FormData formData = FormData.fromMap({
      "bill": await MultipartFile.fromFile(billFile.path),
      "coordinates": points == null ? null : points
    });

    return formData;
  }

}
final HttpService httpService = HttpService();
