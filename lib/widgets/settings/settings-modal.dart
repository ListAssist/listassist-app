import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsModal {
  mainBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(
                  context, 'Foto machen', Icons.camera_alt, ImageSource.camera),
              _createTile(
                  context, 'Galerie', Icons.photo_library, ImageSource.gallery),
              //_createTile(context, 'Löschen', Icons.delete, _action3),
            ],
          );
        }
    );
  }

  ListTile _createTile(BuildContext context, String name, IconData icon,
      ImageSource imgSrc) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      onTap: () {
        _pickImage(context, imgSrc);
      },
    );
  }


  _pickImage(BuildContext context, ImageSource imageSource) async {
    try {
      File imageFile = await ImagePicker.pickImage(source: imageSource);

      Navigator.pop(context, imageFile);
    } catch (e) {
      print(e);
    }
  }
}