import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:listassist/models/Bill.dart';

class StorageService {
  final FirebaseStorage _storage =
  FirebaseStorage(storageBucket: "gs://listassist-433b3.appspot.com");

  /// Starts an upload task and saves it to specified path
  StorageUploadTask upload(
      File imageFile,
      String path,
      {bool includeTimestamp = false, String concatString = "_", String ext = "png", StorageMetadata metadata, DateTime timestamp}) {
    /// Set image name on cloudfirestore
    String filePath = '$path${includeTimestamp ? "$concatString${timestamp != null ? timestamp : DateTime.now()}" : ""}.$ext';
    return _storage.ref().child(filePath).putFile(imageFile, metadata);
  }

  List<StorageReference> getImages(List<Bill> bills){
    return bills.map((b) => _storage.ref().child(b.url)).toList();
  }

}

final StorageService storageService = StorageService();
