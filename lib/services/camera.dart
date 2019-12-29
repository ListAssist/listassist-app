import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/widgets/camera-scanner/camera_scanner.dart';

class CameraService {
  /// pick low level image
  Future<Map<String, dynamic>> pickImage(ImageSource imageSource) async {
    File imageFile = await ImagePicker.pickImage(source: imageSource);
    ui.Image lowLevelImage = await loadLowLevelFromFile(imageFile);
    return {
      "imageFile": imageFile,
      "lowLevelImage": lowLevelImage
    };
  }

  /// picks image from gallery or camera
  Future<File> pickImageFile(ImageSource imageSource) async {
    File imageFile = await ImagePicker.pickImage(source: imageSource);
    return imageFile;
  }

  /// loads image as "low level" (=raw bytes)
  Future<ui.Image> loadLowLevelFromFile(File file) async {
    Uint8List bytes = file.readAsBytesSync();
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  /// Gets response from Camera Scanne
  Future<dynamic> getResultFromCameraScanner(BuildContext context, ImageSource imageSource, { int listIndex }) async {
    try {
      Map<String, dynamic> imageFormats = await cameraService.pickImage(imageSource);
      var _imageFile = imageFormats["imageFile"];
      var _image = imageFormats["lowLevelImage"];

      /// get result from camera scanner
      return await Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScanner(image: _image, imageFile: _imageFile, listIndex: listIndex,)));
    } catch(e)  {
      print(e.toString());
    }
  }
}
final CameraService cameraService = CameraService();
