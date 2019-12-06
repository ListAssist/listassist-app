import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:listassist/models/Bill.dart';

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

  Future<List<dynamic>> getImages(List<Bill> bills){
    return Future.wait(bills.map((b) => _storage.ref().child(b.url).getDownloadURL()));
  }

}

final StorageService storageService = StorageService();
