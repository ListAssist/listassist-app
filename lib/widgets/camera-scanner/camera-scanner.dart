import 'dart:io';
import 'dart:math';
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
import 'package:listassist/services/camera.dart';
import 'package:listassist/services/http.dart';
import 'package:listassist/services/calc.dart';
import 'package:listassist/widgets/camera-scanner/polygon-painter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

enum EditorType {Editor, Trainer, Recognizer}

class CameraScanner extends StatefulWidget {
  @override
  CameraScannerState createState() => CameraScannerState();
}

class CameraScannerState extends State<CameraScanner> {
  ui.Image _image;
  File _imageFile;
  bool _imageLoading = false;

  EditorType _currentEditorType = EditorType.Trainer;
  final double radius = 12;

  List<ui.Offset> _points = [];
  bool _overflow = false;
  int _currentlyDraggedIndex = -1;

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  void setPoints(Rect boundingBox) {
    _points = calcService.getStartingPointsForImage(boundingBox);
  }

  Future _pickImage(ImageSource imageSource) async {
    try {
      setState(() { _imageLoading = true; });
      Map<String, dynamic> imageFormats = await cameraService.pickImage(imageSource);
      setState(() {
        _imageFile = imageFormats["imageFile"];
        _image = imageFormats["lowLevelImage"];
        _imageLoading = false;
        _points = calcService.getStartingPointsForImage(PolygonPainter.outputSubrect);
      });
      SystemChrome.setEnabledSystemUIOverlays([]);
    } catch(e)  {
      print(e.toString());
      setState(() { _imageLoading = false; });
    }
  }

  void _clearPicture() {
    setState(() {
      _imageFile = null;
      _points = [];
    });
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    ProgressDialog progressDialog = ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true);
    progressDialog.style(
        message: "Rechnung wird hochgeladen..",
        borderRadius: 10.0,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
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
              labelBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
              labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              onTap: () async {
                await httpService.getDetections(_imageFile, calcService.exportPoints([_points[0], _points[2], _points[4], _points[6]], _image, PolygonPainter.outputSubrect));
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
            labelBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white,
            labelStyle: TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
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
            File cropped = await ImageCropper.cropImage(
                sourcePath: _imageFile.path,
                androidUiSettings: AndroidUiSettings(toolbarTitle: "Foto bearbeiten"),
                compressFormat: ImageCompressFormat.png,
                compressQuality: 100
            );
            if (cropped != null) {
              ui.Image newImage = await cameraService.loadLowLevelFromFile(cropped);
              setState(() {
                _imageFile = cropped;
                _image = newImage;
              });
            }
          }
        }
      ) : null,
      appBar: _imageFile != null ? null : appBar,
      backgroundColor: _imageFile != null ? Colors.black : (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white),
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
                  padding: EdgeInsets.only(top: 40, bottom: 40),
                  child: Text("oder", textScaleFactor: 2,),
                ),
                FlatButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  color: Colors.brown,
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.photo, color: Colors.white,),
                      Text("Aus der Galerie", style: TextStyle(color: Colors.white),)
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
                          if (distance <= radius) {
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
                          if (_currentlyDraggedIndex % 2 == 0) {
                            ui.Offset correctedOffset = calcService.correctCollisions(details.localPosition, PolygonPainter.outputSubrect);
                            /// Check if angles are correct of each point of polygon using law of cosine
                            List<ui.Offset> futurePoints = List.from(_points);
                            futurePoints[_currentlyDraggedIndex] = correctedOffset;
                            futurePoints = calcService.recalculateMiddlePoints(futurePoints);
                            if (calcService.checkAngles(futurePoints)) {
                              setState(() {
                                _points = futurePoints;
                                _overflow = false;
                              });
                            } else {
                              setState(() {
                                _overflow = true;
                              });
                            }
                          } else {
                            List<ui.Offset> newPoints = List.from(_points);
                            /// case 1 and 5 are cases where the polygon gets pulled in the x direction
                            /// case 3 and 7 are cases where the polygon gets pulled in the y direction
                            switch (_currentlyDraggedIndex) {
                              case 1:
                                calcService.correctedPolygonCoordinates(newPoints, PolygonPainter.outputSubrect, details.delta, dy: false, fromIndex: 0, toIndex: 3);
                                break;
                              case 5:
                                calcService.correctedPolygonCoordinates(newPoints, PolygonPainter.outputSubrect, details.delta, dy: false, fromIndex: 4, toIndex: 6);
                                break;
                              case 3:
                                calcService.correctedPolygonCoordinates(newPoints, PolygonPainter.outputSubrect, details.delta, dx: false, fromIndex: 2, toIndex: 4);
                                break;
                              case 7:
                                calcService.correctedPolygonCoordinates(newPoints, PolygonPainter.outputSubrect, details.delta, dx: false, fromIndex: 6, toIndex: 8);
                                break;
                            }
                            /// check if angle is okay
                            if (!calcService.checkAngles(newPoints) || !calcService.checkDistancesPoints(newPoints)) {
                              setState(() {
                                _overflow = true;
                              });
                            } else {
                              setState(() {
                                _points = newPoints;
                                _overflow = false;
                              });
                            }
                          }
                        } else {
                          /// Check if one point will be out of bound and if size is still okay
                          List<ui.Offset> newPoints = List.from(_points);
                          calcService.correctedPolygonCoordinates(newPoints, PolygonPainter.outputSubrect, details.delta);
                          setState(() {
                            _points = newPoints;
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
                        painter: PolygonPainter(points: _points, overflow: _overflow, radius: radius, image: _image, currentType: _currentEditorType, callback: setPoints),
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

