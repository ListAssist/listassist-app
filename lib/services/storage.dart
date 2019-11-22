import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:listassist/models/User.dart';

class StorageService {
  final FirebaseStorage _storage =
  FirebaseStorage(storageBucket: "gs://listassist-433b3.appspot.com");

  /// Starts an upload task
  StorageUploadTask upload(File imageFile, User user) {
    /// Set image name on cloudfirestore
    String filePath = '${user.uid}/${"w"}__${DateTime
        .now()}.png';
    return _storage.ref().child(filePath).putFile(imageFile);
  }

}

final StorageService storageService = StorageService();