import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage =
  FirebaseStorage(storageBucket: "gs://listassist-433b3.appspot.com");

  /// Starts an upload task and saves it to specified path
  StorageUploadTask upload(
      File imageFile,
      String path,
      {bool includeTimestamp = false, String concatString = "_", String ext = "png", StorageMetadata metadata}) {
    /// Set image name on cloudfirestore
    String filePath = '$path${includeTimestamp ? "$concatString${DateTime.now()}" : ""}.$ext';
    return _storage.ref().child(filePath).putFile(imageFile, metadata);
  }

}

final StorageService storageService = StorageService();
