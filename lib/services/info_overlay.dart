import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';

/// Reserved for later use..
class InfoOverlay {

  static void showInfoSnackBar(String message, {Toast toastLength = Toast.LENGTH_LONG}) {
    Fluttertoast.showToast(
        msg: message,
        textColor: Colors.white,
        toastLength: toastLength
    );
  }

  static void showErrorSnackBar(String message, {Toast toastLength = Toast.LENGTH_LONG}) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        timeInSecForIos: 3,
        toastLength: toastLength
    );
  }

  static mainModalBottomSheet(BuildContext context, List<ListTile> tiles) {
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

  static ProgressDialog showDynamicProgressDialog(BuildContext context, String text) {
    ProgressDialog progressDialog = ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true);
    progressDialog.style(
        message: text,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
        progressWidget: SpinKitDoubleBounce(color: Colors.blue,),
        insetAnimCurve: Curves.easeInOut,
        progress: 0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600)
    );
    return progressDialog;
  }

  static showSourceSelectionSheet(BuildContext context, {Function callback}) {
    mainModalBottomSheet(context, [
      ListTile(
        leading: Icon(Icons.camera_alt),
        title: Text("Kamera"),
        onTap: () => callback(context, ImageSource.camera),
      ),
      ListTile(
        leading: Icon(Icons.photo),
        title: Text("Galerie"),
        onTap: () => callback(context, ImageSource.gallery),
      )
    ]);
  }
}
