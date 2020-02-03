import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/services/camera.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info_overlay.dart';
import 'package:listassist/services/storage.dart';
import 'package:listassist/widgets/settings/updateProfileDataDialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProfileSettingsView extends StatefulWidget {
  @override
  _ProfileSettingsView createState() => _ProfileSettingsView();
}

class _ProfileSettingsView extends State<ProfileSettingsView> {
  FirebaseUser _firebaseUser;
  User _user;
  String _uid;
  String _displayName;

  TextEditingController _emailController = TextEditingController();

  File _imageFile;

  String _newName;

  bool _nameChanged = false;

  var updateProfileDataDialog = new UpdateProfileDataDialog();

  var _pr;

  // schaut ob der Name anders ist als der in der DB,
  // wenn ja dann wird der FOAB entsperrt
  _checkName(text) {
    if (_displayName != text) {
      setState(() {
        _nameChanged = true;
        _newName = text;
      });
    } else {
      setState(() {
        _nameChanged = false;
      });
    }
  }

  _saveSettings() async {
    _pr.show();
    var connectivityResult;
    try {
      connectivityResult = await Connectivity().checkConnectivity();
    } on PlatformException catch (e) {
      _pr.hide();
      print(e.toString());
    }
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a network.
      await databaseService.updateProfileName(_uid, _newName);
      _displayName = _newName;
      _nameChanged = false;
      setState(() {});
      _pr.hide();
      InfoOverlay.showInfoSnackBar("Der Anzeigename wurde geändert");
    } else {
      // I am not connected to a network.
      Future.delayed(Duration(seconds: 1)).then((value) async {
        _pr.hide();
        InfoOverlay.showErrorSnackBar("Kein Internetzugriff, versuche es erneut");
      });
    }
  }

  _showProfilePictureModal(user) async {
    await mainBottomSheet(context, user);
  }

  mainBottomSheet(BuildContext context, User user) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(context, 'Foto aufnehmen', Icons.camera_alt, ImageSource.camera, user),
              _createTile(context, 'Galerie', Icons.photo_library, ImageSource.gallery, user),
              //_createTile(context, 'Löschen', Icons.delete, _action3),
            ],
          );
        });
  }

  ListTile _createTile(BuildContext context, String name, IconData icon, ImageSource imgSrc, User user) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      onTap: () async {
        File file = await cameraService.pickImageFile(imgSrc);

        setState(() {
          _imageFile = file;
        });

        File cropped = await ImageCropper.cropImage(sourcePath: _imageFile.path, cropStyle: CropStyle.circle, aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
        if (cropped != null) {
          setState(() {
            _imageFile = cropped;
          });
        }

        ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.Download, isDismissible: true);
        progressDialog.style(
            message: "Rechnung wird hochgeladen..",
            borderRadius: 10.0,
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
            progressWidget: SpinKitDoubleBounce(
              color: Colors.blue,
            ),
            elevation: 10.0,
            insetAnimCurve: Curves.easeInOut,
            progress: 0.0,
            maxProgress: 100.0,
            progressTextStyle: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
            messageTextStyle: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600));

        progressDialog.show();
        final task = storageService.upload(_imageFile, "users/${user.uid}/profile-picture", ext: "png", includeTimestamp: false);
        task.events.listen((event) async {
          if (!progressDialog.isShowing()) {
            task.cancel();
            progressDialog.dismiss();
            InfoOverlay.showErrorSnackBar("Hochladevorgang wurde abgebrochen");
            return;
          }

          var snap = event.snapshot;
          double progressPercent = snap != null ? snap.bytesTransferred / snap.totalByteCount : 0;
          if (progressDialog.isShowing()) {
            progressDialog.update(progress: (progressPercent * 100).round().toDouble(), message: progressPercent > .70 ? "Fast fertig.." : "Profilbild wird hochgeladen..");
            if (task.isSuccessful) {
              progressDialog.hide();
              snap.ref.getDownloadURL().then((onValue) => {authService.setProfilePicture(user, onValue)});
            }
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser firebaseUser = Provider.of<FirebaseUser>(context);
    User user = Provider.of<User>(context);
    _firebaseUser = firebaseUser;
    _user = user;
    _uid = user.uid;
    _displayName = user.displayName;

    _emailController.text = user.email;

    _pr = new ProgressDialog(context, type: ProgressDialogType.Normal, isDismissible: true);
    _pr.style(
        message: "Aktualisiere Benutzernamen...",
        borderRadius: 4.0,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
        progressWidget: SpinKitDoubleBounce(
          color: Colors.blue,
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600));

    return Scaffold(
      //backgroundColor: Colors.transparent,
      //key: _scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
      ),
      body: Container(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20),
          decoration: BoxDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: GestureDetector(
                  onTap: () {
                    _showProfilePictureModal(user);
                  },
                  child: Hero(
                    tag: "profilePicture",
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl),
                      radius: 50,
                    ),
                  )),
            ),
            Container(
                margin: const EdgeInsets.only(bottom: 50.0),
                child: GestureDetector(
                    onTap: () {
                      _showProfilePictureModal(user);
                    },
                    child: Text(
                      "Foto ändern",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: TextAlign.center,
                    ))),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: TextFormField(
                initialValue: user.displayName,
                onChanged: (text) {
                  _checkName(text);
                },
                decoration: InputDecoration(labelText: 'Name', icon: Icon(Icons.account_circle)),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: Row(children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-Mail',
                      icon: Icon(Icons.email),
                    ),
                    enabled: false,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    updateProfileDataDialog.showLoginDialog(context, firebaseUser, user, "email");
                  },
                )
              ]),
            ),
            Row(children: <Widget>[
              Expanded(
                child: TextFormField(
                  initialValue: "kekomat11",
                  decoration: InputDecoration(
                    labelText: 'Passwort',
                    icon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  enabled: false,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  updateProfileDataDialog.showLoginDialog(context, firebaseUser, user, "password");
                },
              )
            ]),
          ])),

      floatingActionButton: FloatingActionButton(
        onPressed: _nameChanged
            ? () {
                _saveSettings();
              }
            : null,
        child: Icon(Icons.save),
        backgroundColor: _nameChanged ? Colors.green : Colors.grey,
      ),
    );
  }
}
