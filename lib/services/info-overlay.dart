import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

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

  static mainBottomSheet(BuildContext context, List<ListTile> tiles) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: tiles
          );
        }
    );
  }

  static ListTile createTile(String name, IconData icon, {Function onTap}) {
    return ListTile(
        leading: Icon(icon),
        title: Text(name),
    );
  }
}
