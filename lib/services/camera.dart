import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  Future<Map<String, dynamic>> pickImage(ImageSource imageSource) async {
    File imageFile = await ImagePicker.pickImage(source: imageSource);
    ui.Image lowLevelImage = await loadLowLevelFromFile(imageFile);
    return {
      "imageFile": imageFile,
      "lowLevelImage": lowLevelImage
    };
  }

  Future<File> pickImageFile(ImageSource imageSource) async {
    File imageFile = await ImagePicker.pickImage(source: imageSource);
    return imageFile;
  }

  Future<ui.Image> loadLowLevelFromFile(File file) async {
    Uint8List bytes = file.readAsBytesSync();
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }
}
final CameraService cameraService = CameraService();
