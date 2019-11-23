import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:after_init/after_init.dart';
import 'package:flutter/services.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:listassist/models/User.dart';
import 'package:listassist/services/camera.dart';
import 'package:listassist/services/http.dart';
import 'package:listassist/services/calc.dart';
import 'package:listassist/services/info-overlay.dart';
import 'package:listassist/services/storage.dart';
import 'package:listassist/widgets/camera-scanner/polygon-painter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

enum EditorType {Editor, Trainer, Recognizer}

class CameraScanner extends StatefulWidget {
  final ui.Image image;
  final File imageFile;

  const CameraScanner({Key key, @required this.image, @required this.imageFile}) : super(key: key);

  @override
  CameraScannerState createState() => CameraScannerState();
}

class CameraScannerState extends State<CameraScanner> with AfterInitMixin<CameraScanner> {
  ui.Image _image;
  File _imageFile;
  final GlobalKey<FancyBottomNavigationState> bottomNavKey = GlobalKey<FancyBottomNavigationState>();

  EditorType _currentEditorType = EditorType.Trainer;
  final double radius = 12;

  List<ui.Offset> _points = [];
  bool _overflow = false;
  int _currentlyDraggedIndex = -1;

  Rect boundingBox;
  Rect inputRect;


  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  void initState() {
    super.initState();
    _image = widget.image;
    _imageFile = widget.imageFile;
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void didInitState() {
    getInputRectAndBoundingRect();
    setState(() {
      _points = calcService.getStartingPointsForImage(boundingBox);
    });
  }

  void getInputRectAndBoundingRect() {
    final outputRect = Rect.fromPoints(ui.Offset.zero, ui.Offset(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - 12));
    final Size imageSize = Size(_image.width.toDouble(), _image.height.toDouble());
    final FittedSizes sizes = applyBoxFit(BoxFit.contain, imageSize, outputRect.size);
    setState(() {
      inputRect = Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
      boundingBox = Alignment.center.inscribe(sizes.destination, outputRect);
    });
  }

  void _clearPicture() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);

    return Scaffold(
      floatingActionButton: SpeedDial(
        marginBottom: 60,
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
                ProgressDialog dialog = InfoOverlay.showDynamicProgressDialog(context, "Rechnung wird hochgeladen..");
                dialog.show();
                try {
                  /// Upload for detection
                  await httpService.getDetections(
                      _imageFile,
                      calcService.exportPoints(
                        [_points[0], _points[2], _points[4], _points[6]],
                        _image,
                        boundingBox,
                      ),
                      onProgress: (int sent, int total) {
                        double percentage = (sent * 100 / total).roundToDouble();
                        dialog.update(progress: percentage / 2);
                      }
                  );

                  /// Upload to firestore
                  var task = storageService.upload(_imageFile, "${user.uid}/lists/qjiwej1i23j/", concatString: "");
                  task.events.listen((event) async {
                    if (task.isInProgress) {
                      double percentage = (event.snapshot.bytesTransferred * 100 / event.snapshot.totalByteCount).roundToDouble();
                      dialog.update(progress: 50 + percentage / 2, message: percentage / 2 > 50 ? "Fast fertig.." : null);
                    }
                  });
                  await task.onComplete;
                } catch (e) {
                  InfoOverlay.showErrorSnackBar("Hochladevorgang fehlgeschlagen.");
                } finally {
                  dialog.dismiss();
                }
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
      ),
      bottomNavigationBar: FancyBottomNavigation(
        key: bottomNavKey,
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
                getInputRectAndBoundingRect();
                _points = calcService.getStartingPointsForImage(boundingBox);
              });
            }
          }
        }
      ),
      backgroundColor: _imageFile != null ? Colors.black : (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : Colors.white),
      body: GestureDetector(
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
                ui.Offset correctedOffset = calcService.correctCollisions(details.localPosition, boundingBox);
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
                    calcService.correctedPolygonCoordinates(newPoints, boundingBox, details.delta, dy: false, fromIndex: 0, toIndex: 3);
                    break;
                  case 5:
                    calcService.correctedPolygonCoordinates(newPoints, boundingBox, details.delta, dy: false, fromIndex: 4, toIndex: 6);
                    break;
                  case 3:
                    calcService.correctedPolygonCoordinates(newPoints, boundingBox, details.delta, dx: false, fromIndex: 2, toIndex: 4);
                    break;
                  case 7:
                    calcService.correctedPolygonCoordinates(newPoints, boundingBox, details.delta, dx: false, fromIndex: 6, toIndex: 8);
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
              calcService.correctedPolygonCoordinates(newPoints, boundingBox, details.delta);
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
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - 60),
            painter: PolygonPainter(points: _points, overflow: _overflow, radius: radius, image: _image, currentType: _currentEditorType, boundingBox: boundingBox, inputRect: inputRect),
          )
      ),
    );
  }
}
