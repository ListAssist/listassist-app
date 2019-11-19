import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/http.dart';
import 'package:listassist/services/math.dart';
import 'package:listassist/services/snackbar.dart';
import 'package:listassist/widgets/camera-scanner/rectangle-painter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

enum EditorType {Editor, Trainer, Recognizer}

class PictureShow extends StatefulWidget {
  @override
  _PictureShowState createState() => _PictureShowState();
}

class _PictureShowState extends State<PictureShow> {
  ui.Image _image;
  File _imageFile;
  bool _imageLoading = false;

  EditorType _currentEditorType = EditorType.Trainer;

  List<ui.Offset> _points = [ui.Offset(90, 120), ui.Offset(90, 370), ui.Offset(320, 370), ui.Offset(320, 120)];
  bool _angleOverflow = false;
  int _currentlyDraggedIndex = -1;

  int currentPage;

  Future _pickImage(ImageSource imageSource) async {
    try {
      setState(() { _imageLoading = true; });

      File imageFile = await ImagePicker.pickImage(source: imageSource);
      ui.Image finalImg = await _load(imageFile);
      setState(() {
        _imageFile = imageFile;
        _image = finalImg;
        _imageLoading = false;
      });
      SystemChrome.setEnabledSystemUIOverlays([]);
    } catch(e)  {
      print(e.toString());
      setState(() { _imageLoading = false; });
    }
  }

  Future<ui.Image> _load(File file) async {
    Uint8List bytes = file.readAsBytesSync();
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  void _clearPicture() {
    setState(() {
      _imageFile = null;
      List<ui.Offset> _points = [ui.Offset(90, 120), ui.Offset(90, 370), ui.Offset(320, 370), ui.Offset(320, 120)];
    });
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  List<Map<String, double>> exportPoints() {
    double ratioX = _image.width / RectanglePainter.outputSubrect.width;
    double ratioY = _image.height / RectanglePainter.outputSubrect.height;
    return _points.map((Offset point) {
      return {
        "x": point.dx * ratioX,
        "y": (point.dy - RectanglePainter.outputSubrect.top) * ratioY
      };
    }).toList();
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
        overlayOpacity: 0,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.check),
              backgroundColor: Colors.green,
              label: "Complete",
              labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white),
              onTap: () async {
                await httpService.getDetections(_imageFile, exportPoints());
                  /*
                progressDialog.show();
                final task = storageService.upload(_imageFile, user);
                task.events.listen((event) async {
                  if (!progressDialog.isShowing()) {
                    task.cancel();
                    progressDialog.dismiss();
                    InfoSnackbar.showErrorSnackBar("Hochladevorgang wurde abgebrochen");
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
                 */
              }
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            backgroundColor: Colors.red,
            label: "Delete",
            labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white),
            onTap: () {
                _clearPicture();
            },
          )
        ],
      ) : null,
      bottomNavigationBar: _imageFile != null ? FancyBottomNavigation(
        initialSelection: 1,
        tabs: [
          TabData(iconData: Icons.crop, title: "Editor"),
          TabData(iconData: Icons.extension, title: "Trainer"),
          TabData(iconData: Icons.chrome_reader_mode, title: "Auto Detection")
        ],
        onTabChangedListener: (position) async {
          setState(() {
            _currentEditorType = EditorType.values[position];
          });
          /// Open Crop widget if user chooses to use cropping
          if (_currentEditorType == EditorType.Editor) {
            File cropped = await ImageCropper.cropImage(sourcePath: _imageFile.path);
            if (cropped != null) {
              ui.Image newImage = await _load(cropped);
              setState(() async {
                _imageFile = cropped;
                _image = newImage;
              });
            }
          }
        }
      ) : null,
      appBar: _imageFile != null ? null : appBar,
      backgroundColor: _imageFile != null ? Colors.black : Colors.white,
      body: AnimatedSwitcher(
        duration: Duration(seconds: 1),
        child: _imageLoading ?  SpinKitDoubleBounce(color: Theme.of(context).primaryColor) : Center(
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
                  GestureDetector(
                      onPanStart: (DragStartDetails details) {
                        // get distance from points to check if is in circle
                        int indexMatch = -1;
                        double lastDistance = -1;
                        for (int i = 0; i < _points.length; i++) {
                          double distance = sqrt(pow(details.localPosition.dx - _points[i].dx, 2) + pow(details.localPosition.dy - _points[i].dy, 2));
                          if (distance <= 30) {
                            if (distance < lastDistance || lastDistance == -1) {
                              indexMatch = i;
                              lastDistance = distance;
                            }
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
                          if (details.localPosition.dx < RectanglePainter.outputSubrect.left) {
                            correctedOffset = Offset(RectanglePainter.outputSubrect.left, correctedOffset.dy);
                          } else if (details.localPosition.dx > RectanglePainter.outputSubrect.right) {
                            correctedOffset = Offset(RectanglePainter.outputSubrect.right, correctedOffset.dy);
                          }

                          /// Check if angles are correct of each point of polygon using law of cosine
                          List<ui.Offset> futurePoints = List.from(_points);
                          futurePoints[_currentlyDraggedIndex] = correctedOffset;
                          if (mathService.calculateAngle(futurePoints, 0, 1, 3) &&
                              mathService.calculateAngle(futurePoints, 1, 2, 0) &&
                              mathService.calculateAngle(futurePoints, 2, 3, 1) &&
                              mathService.calculateAngle(futurePoints, 3, 0, 2)) {
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
                            if (correctedOffset.dx < RectanglePainter.outputSubrect.left) {
                              correctedOffset = Offset(RectanglePainter.outputSubrect.left, correctedOffset.dy);
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
                        painter: RectanglePainter(points: _points, angleOverflow: _angleOverflow, image: _image, currentType: _currentEditorType),
                      )
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

