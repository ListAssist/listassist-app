import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:listassist/models/User.dart';

class StorageService {
  final FirebaseStorage _storage =
  FirebaseStorage(storageBucket: "gs://listassist-433b3.appspot.com");

  /// Starts an upload task and saves it to specified path
  StorageUploadTask upload(File imageFile, String path, {bool includeTimestamp = true, String concatString = "_", String ext = "png"}) {
    /// Set image name on cloudfirestore
    String filePath = '$path${includeTimestamp ? "$concatString${DateTime.now()}" : ""}.$ext';
    return _storage.ref().child(filePath).putFile(imageFile);
  }

}

final StorageService storageService = StorageService();