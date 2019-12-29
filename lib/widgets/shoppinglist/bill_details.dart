import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class BillDetails extends StatefulWidget {
  final StorageReference image;
  BillDetails({this.image});

  @override
  _BillDetailsState createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {
  @override
  Widget build(BuildContext context) {
    widget.image.getMetadata().then((val) => {
      print(val.customMetadata["detected_products"])
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
    );
  }
}
