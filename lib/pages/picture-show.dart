import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listassist/services/recognize.dart';

class PictureShow extends StatefulWidget {
  final Image image;
  final File imageFile;

  PictureShow({Key key, @required this.image, @required this.imageFile}): super(key: key);

  @override
  _PictureShowState createState() => _PictureShowState();
}

class _PictureShowState extends State<PictureShow> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          child: widget.image,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                  RawMaterialButton(
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 25,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.redAccent,
                    padding: EdgeInsets.all(10.0),
                  ),
                  RawMaterialButton(
                    onPressed: () => recognizeService.recognizeText(widget.imageFile),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 25,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.green,
                    padding: EdgeInsets.all(10.0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}