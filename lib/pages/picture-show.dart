import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/services/recognize.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';

class PictureShow extends StatefulWidget {
  @override
  _PictureShowState createState() => _PictureShowState();
}

class _PictureShowState extends State<PictureShow> {
  File _imageFile;
  List<Offset> _points = [];
  bool _clear = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
        FloatingActionButton(
          child: Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _clear = true;
              _points = [];
            });
          }
        ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Rechungserkennung"),
      ),
      backgroundColor: _imageFile != null ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_imageFile == null) ...[
              FlatButton(
                onPressed: () => _pickImage(ImageSource.camera),
                color: Colors.blueAccent,
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.camera_alt, color: Colors.white,),
                    Text("Aus der Kamera", style: TextStyle(color: Colors.white),)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40),
                child: Text("oder", textScaleFactor: 2,),
              ),
              FlatButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                color: Colors.brown,
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.photo, color: Colors.white,),
                    Text("Aus der Gallerie", style: TextStyle(color: Colors.white),)
                  ],
                ),
              ),
            ],
            if (_imageFile != null) ...[
              Container(
                child: PositionedTapDetector(
                    onTap: (TapPosition pos) {
                      setState(() {
                        if (_points.length <= 3) {
                          _clear = false;
                          _points = List.from(_points)..add(pos.relative);
                        }
                      });
                    },
                    child: Stack(
                      children: [
                        Image.file(_imageFile),
                        CustomPaint(
                            size: Size.infinite,
                            painter: RectanglePainter(points: _points, clear: _clear),
                            child: Container()
                        ),
                      ]
                    )
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Future _pickImage(ImageSource imageSource) async {
    try {
      File image = await ImagePicker.pickImage(source: imageSource);

      setState(() {
        _imageFile = image;
      });
    } on Exception {
      ResultHandler
          .showInfoSnackbar(Text("Ein Fehler ist aufgetreten beim Öffnen des Bildes. Die App benötigt Zugriff auf die Galerie"));
    }
  }

}


class RectanglePainter extends CustomPainter {
  List<Offset> points;
  bool clear;

  RectanglePainter({@required this.points, @required this.clear});

  @override
  void paint(Canvas canvas, Size size) {
    if (!clear) {
      final paint = Paint()
        ..color = Colors.red
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      if (points.isNotEmpty && points != null) {
        if (points.length == 1) {
          canvas.drawPoints(PointMode.points, [points[0]], paint);
        } else if (points.length == 2) {
          canvas.drawLine(points[0], points[1], paint);
        } else if (points.length == 3) {
          canvas.drawLine(points[0], points[1], paint);
          canvas.drawLine(points[1], points[2], paint);

          /* double x = points[2].dx - points[1].dx;
             double y = points[2].dy - points[1].dy;

          points.add(Offset(points[0].dx + x, points[0].dy + y));
          canvas.drawLine(points[2], points[3], paint);
          canvas.drawLine(points[3], points[0], paint);
           */
        } else {
          canvas.drawLine(points[0], points[1], paint);
          canvas.drawLine(points[1], points[2], paint);
          canvas.drawLine(points[2], points[3], paint);
          canvas.drawLine(points[3], points[0], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(RectanglePainter oldPainter) => oldPainter.points != points || clear ;

}