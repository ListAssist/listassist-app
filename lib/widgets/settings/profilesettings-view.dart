import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/services/camera.dart';
import 'package:listassist/services/db.dart';
import 'package:listassist/services/info-overlay.dart';
import 'package:listassist/services/storage.dart';
import 'package:listassist/validators/email.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class ProfileSettingsView extends StatefulWidget {
  @override
  _ProfileSettingsView createState() => _ProfileSettingsView();
}

class _ProfileSettingsView extends State<ProfileSettingsView> {

  String _uid;
  String _displayName;
  String _email;

  File _imageFile;

  String _newName;
  String _newEmail;

  bool _nameChanged = false;
  bool _emailChanged = false;


  // schaut ob der Name anders ist als der in der DB,
  // wenn ja dann wird der FOAB entsperrt
  _checkName(text) {
    if(_displayName != text) {
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

  _checkEmail(text) {
    if(_email != text) {
      setState(() {
        _emailChanged = true;
        _newEmail = text;
      });
    } else {
      setState(() {
        _emailChanged = false;
      });
    }
  }

  _saveSettings() {
    if(_nameChanged) {
      databaseService.updateProfileName(_uid, _newName);
      _displayName = _newName;
      _nameChanged = false;
    }
    if(_emailChanged) {
      databaseService.updateEmail(_uid, _newEmail);
      _email = _newEmail;
      _emailChanged = false;
    }
  }

  _showProfilePictureModal(user) async{
    await mainBottomSheet(context, user);
  }

  mainBottomSheet(BuildContext context, User user) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(
                  context, 'Foto aufnehmen', Icons.camera_alt, ImageSource.camera, user),
              _createTile(
                  context, 'Galerie', Icons.photo_library, ImageSource.gallery, user),
              //_createTile(context, 'Löschen', Icons.delete, _action3),
            ],
          );
        }
    );
  }

  ListTile _createTile(BuildContext context, String name, IconData icon, ImageSource imgSrc, User user) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      onTap: () async{
        print("keeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeek");

        File file = await cameraService.pickImageFile(imgSrc);
        print("keeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeek");

        setState(() {
          _imageFile = file;
        });

        print("keeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeek");
        File cropped = await ImageCropper.cropImage(sourcePath: _imageFile.path, cropStyle: CropStyle.circle, aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
        if (cropped != null) {
          setState(() {
            _imageFile = cropped;
          });
        }

        ProgressDialog progressDialog = ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true);
        progressDialog.style(
            message: "Rechnung wird hochgeladen..",
            borderRadius: 10.0,
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
            progressWidget: SpinKitDoubleBounce(color: Colors.blue,),
            elevation: 10.0,
            insetAnimCurve: Curves.easeInOut,
            progress: 0.0,
            maxProgress: 100.0,
            progressTextStyle: TextStyle(
                color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
            messageTextStyle: TextStyle(
                color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600)
        );

        progressDialog.show();
        final task = storageService.upload(_imageFile, user);
        task.events.listen((event) async {
          if (!progressDialog.isShowing()) {
            task.cancel();
            progressDialog.dismiss();
            InfoOverlay.showErrorSnackBar("Hochladevorgang wurde abgebrochen");
            return;
          }

          var snap = event.snapshot;
          double progressPercent = snap != null
              ? snap.bytesTransferred / snap.totalByteCount
              : 0;
          if (progressDialog.isShowing()) {
            progressDialog.update(
                progress: (progressPercent * 100).round().toDouble(),
                message: progressPercent > .70 ? "Fast fertig.." : "Rechnung wird hochgeladen.."
            );
            if (task.isSuccessful) {
              progressDialog.hide();
              snap.ref.getDownloadURL().then((onValue) => {
                authService.setProfilePicture(user, onValue)
              });
            }
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    User user  = Provider.of<User>(context);
    _uid = user.uid;
    _displayName = user.displayName;
    _email = user.email;

    return Scaffold(
      //backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: Container(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            decoration: BoxDecoration(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                        onTap: () { _showProfilePictureModal(user); },
                      child:
                        Hero(
                          tag: "profilePicture",
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(user.photoUrl),
                            radius: 50,
                          ),
                        )
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 50.0),

                    child: GestureDetector(
                        onTap: () { _showProfilePictureModal(user); },
                        child:
                      Text(
                        "Foto ändern",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        textAlign: TextAlign.center,
                      )
                    )
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child:
                      TextFormField(
                        initialValue: user.displayName,
                        onChanged: (text) {
                          _checkName(text);
                        },
                        decoration: InputDecoration(
                          labelText: 'Name',
                          icon: Icon(Icons.account_circle)
                        ),
                      ),
                  ),
                  TextFormField(
                    initialValue: user.email,
                    autovalidate: true,
                    onChanged: (text) {
                      _checkEmail(text);
                    },
                    decoration: InputDecoration(
                      labelText: 'E-Mail',
                      icon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: EmailValidator(),
                  ),

                ])
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: _nameChanged || _emailChanged ? (){ _saveSettings(); } : null,
          child: Icon(Icons.save),
          backgroundColor: _nameChanged || _emailChanged ? Colors.green : Colors.grey,
        ),
    );
  }
}