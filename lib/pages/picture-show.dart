import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/services/auth.dart';

class PictureShow extends StatefulWidget {
  @override
  _PictureShowState createState() => _PictureShowState();
}

class _PictureShowState extends State<PictureShow> {
  File _imageFile;
  List<Offset> _points = [Offset(90, 120), Offset(90, 370), Offset(320, 370), Offset(320, 120)];
  bool _clear = false;
  int _currentlyDraggedIndex = -1;

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
                child: GestureDetector(
                    onPanStart: (DragStartDetails details) {
                      // get distance from points to check if is in circle
                      int indexMatch = -1;
                      for (int i = 0; i < _points.length; i++) {
                        double distance = sqrt(pow(details.localPosition.dx - _points[i].dx, 2) + pow(details.localPosition.dy - _points[i].dy, 2));
                        if (distance <= 30) {
                          indexMatch = i;
                          break;
                        }
                      }
                      if (indexMatch != -1) {
                        _currentlyDraggedIndex = indexMatch;
                      }
                    },
                    onPanUpdate: (DragUpdateDetails details) {
                      if (_currentlyDraggedIndex != -1) {
                        setState(() {
                          _points = List.from(_points);
                          _points[_currentlyDraggedIndex] = details.localPosition;
                        });
                      }
                    },
                    onPanEnd: (_) {
                      setState(() {
                        _currentlyDraggedIndex = -1;
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
              ),
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
        ..style = PaintingStyle.fill
        ..strokeWidth = 2;
      final circlePaint = Paint()
        ..color = Colors.red
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.multiply
        ..strokeWidth = 2;

      for (int i = 0; i < points.length; i++) {
          if (i + 1 == points.length) {
            canvas.drawLine(points[i], points[0], paint);
          } else {
            canvas.drawLine(points[i], points[i + 1], paint);
          }
          canvas.drawCircle(points[i], 10, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(RectanglePainter oldPainter) => oldPainter.points != points || clear ;

}