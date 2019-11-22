import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Reserved for later use..
class InfoOverlay {

  static void showInfoSnackBar(String message) {
    Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
    );
  }

  static void showErrorSnackBar(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.red,
        textColor: Colors.white,
    );
  }

}
