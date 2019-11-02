import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/auth.dart';
import 'package:listassist/services/storage.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class PictureShow extends StatefulWidget {
  @override
  _PictureShowState createState() => _PictureShowState();
}

class _PictureShowState extends State<PictureShow> {
  ui.Image _image;
  File _imageFile;
  List<ui.Offset> _points = [ui.Offset(90, 120), ui.Offset(90, 370), ui.Offset(320, 370), ui.Offset(320, 120)];
  bool _angleOverflow = false;
  int _currentlyDraggedIndex = -1;

  Future _pickImage(ImageSource imageSource) async {
    try {
      File imageFile = await ImagePicker.pickImage(source: imageSource);
      ui.Image finalImg = await _load(imageFile.path);
      setState(() {
        _imageFile = imageFile;
        _image = finalImg;
      });
    } catch(e)  {
      print(e);
    }
  }

  Future<ui.Image> _load(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  void _clearPicture() {
    setState(() => _imageFile = null);
  }

  /// Calculate angle for point with law of cosine
  /// @params are just the indeces of the points in the array
  bool calculateAngle(List<ui.Offset> futurePoints, int mainIndex, int beforeIndex, int afterIndex) {
    double a = sqrt(pow(futurePoints[mainIndex].dx - futurePoints[beforeIndex].dx, 2) + pow(futurePoints[mainIndex].dy - futurePoints[beforeIndex].dy, 2));
    double b = sqrt(pow(futurePoints[mainIndex].dx - futurePoints[afterIndex].dx, 2) + pow(futurePoints[mainIndex].dy - futurePoints[afterIndex].dy, 2));
    double c = sqrt(pow(futurePoints[afterIndex].dx - futurePoints[beforeIndex].dx, 2) + pow(futurePoints[afterIndex].dy - futurePoints[beforeIndex].dy, 2));
    double angle = acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b)) * (180 / pi);
    return angle < 120 && angle > 20;
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    ProgressDialog progressDialog = ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true);
    progressDialog.style(
        message: "Rechnung wird hochgeladen..",
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: SpinKitDoubleBounce(color: Colors.blue,),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600)
    );

    final AppBar appBar = AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text("Rechungserkennung"),
    );

    return Scaffold(
      floatingActionButton: _imageFile != null ? SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        closeManually: false,
        curve: Curves.easeIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.35,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.check),
              backgroundColor: Colors.green,
              label: "Complete",
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                progressDialog.show();
                final task = storageService.upload(_imageFile, user);
                task.events.listen((event) async {
                  if (!progressDialog.isShowing()) {
                    task.cancel();
                    progressDialog.dismiss();
                    /// ResultHandler.showInfoSnackbar(Text("Hochladevorgang unterbrochen"), auth: false);
                    return;
                  }

                  var snap = event.snapshot;
                  double progressPercent = snap != null
                      ? snap.bytesTransferred / snap.totalByteCount
                      : 0;
                  if (progressDialog.isShowing()) {
                    progressDialog.update(
                        progress: (progressPercent * 100).round().toDouble(),
                        message: progressPercent > .70 ? "Fast fertig.." : "Rechnung wird hochgeladen.."
                    );
                    if (task.isSuccessful) {
                      progressDialog.hide();
                    }
                  }
                });
              }
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            backgroundColor: Colors.red,
            label: "Delete",
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                _clearPicture();
                _points = [];
              });
            },
          )
        ],
      ) : null,
      appBar: appBar,
      backgroundColor: _imageFile != null ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              ClipRect(
                clipBehavior: Clip.hardEdge,
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
                        Offset correctedOffset = details.localPosition;

                        /// Check if out of bound
                        if (details.localPosition.dy - RectanglePainter.outputSubrect.top < 0) {
                          correctedOffset = Offset(correctedOffset.dx, RectanglePainter.outputSubrect.top);
                        } else if (details.localPosition.dy > RectanglePainter.outputSubrect.bottom) {
                          correctedOffset = Offset(correctedOffset.dx, RectanglePainter.outputSubrect.bottom);
                        }
                        if (details.localPosition.dx < 0) {
                          correctedOffset = Offset(0, correctedOffset.dy);
                        } else if (details.localPosition.dx > RectanglePainter.outputSubrect.right) {
                          correctedOffset = Offset(RectanglePainter.outputSubrect.right, correctedOffset.dy);
                        }

                        /// Check if angles are correct of each point of polygon using law of cosine
                        List<ui.Offset> futurePoints = List.from(_points);
                        futurePoints[_currentlyDraggedIndex] = correctedOffset;
                        if (calculateAngle(futurePoints, 0, 1, 3) &&
                            calculateAngle(futurePoints, 1, 2, 0) &&
                            calculateAngle(futurePoints, 2, 3, 1) &&
                            calculateAngle(futurePoints, 3, 0, 2)) {
                          setState(() {
                            _points = futurePoints;
                            _angleOverflow = false;
                          });
                        } else {
                          setState(() {
                            _angleOverflow = true;
                          });
                        }
                      } else {
                        /// Check if one point will be out of bound
                        List<ui.Offset> futurePoints = _points.map((Offset point) {
                          Offset correctedOffset = point + details.delta;
                          /// Y Axis collisions
                          if (correctedOffset.dy - RectanglePainter.outputSubrect.top < 0) {
                            correctedOffset = Offset(correctedOffset.dx, RectanglePainter.outputSubrect.top);
                          } else if (correctedOffset.dy > RectanglePainter.outputSubrect.bottom) {
                            correctedOffset = Offset(correctedOffset.dx, RectanglePainter.outputSubrect.bottom);
                          }
                          /// X Axis collisions
                          if (correctedOffset.dx < 0) {
                            correctedOffset = Offset(0, correctedOffset.dy);
                          } else if (correctedOffset.dx > RectanglePainter.outputSubrect.right) {
                            correctedOffset = Offset(RectanglePainter.outputSubrect.right, correctedOffset.dy);
                          }
                          return correctedOffset;
                        }).toList();
                        setState(() {
                          _points = futurePoints;
                        });
                      }
                    },
                    onPanEnd: (_) {
                      setState(() {
                        _currentlyDraggedIndex = -1;
                      });
                    },
                    child: CustomPaint(
                      size: Size.fromHeight(MediaQuery.of(context).size.height - appBar.preferredSize.height - 24),
                      painter: RectanglePainter(points: _points, angleOverflow: _angleOverflow, image: _image),
                    )
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class RectanglePainter extends CustomPainter {
  List<Offset> points;
  bool angleOverflow;
  final ui.Image image;
  static Rect outputSubrect;

  RectanglePainter({@required this.points, @required this.angleOverflow, @required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    Color mainColor = angleOverflow ? Colors.red : Colors.indigo;
    /// paint for lines
    final paint = Paint()
      ..color = mainColor
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    /// paint for circle
    final circlePaint = Paint()
      ..color = mainColor
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.multiply
      ..strokeWidth = 2;
    final double radius = 10;

    final outputRect = Rect.fromPoints(ui.Offset.zero, ui.Offset(size.width, size.height));
    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final FittedSizes sizes = applyBoxFit(BoxFit.contain, imageSize, outputRect.size);
    final Rect inputSubrect = Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    /// outputSubrect is the real bounding box for the canvas
    outputSubrect = Alignment.center.inscribe(sizes.destination, outputRect);
    canvas.drawImageRect(image, inputSubrect, outputSubrect, paint);

    for (int i = 0; i < points.length; i++) {
      if (i + 1 == points.length) {
        canvas.drawLine(points[i], points[0], paint);
      } else {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], radius, circlePaint);
      TextSpan span = TextSpan(style: TextStyle(color: Colors.white), text: "${i+1}");
      TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(points[i].dx - 3.5, points[i].dy - 8));
    }
  }

  @override
  bool shouldRepaint(RectanglePainter oldPainter) => oldPainter.points != points || angleOverflow ;

}