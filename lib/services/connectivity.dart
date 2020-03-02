import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

class ConnectivityService {
  Future<bool> testInternetConnection() async {
    var connectivityResult;
    try {
      connectivityResult = await Connectivity().checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi);
  }
}
final ConnectivityService connectivityService = ConnectivityService();