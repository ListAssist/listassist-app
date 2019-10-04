import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:listassist/pages/picture-show.dart';
import 'package:listassist/services/auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:image_picker/image_picker.dart';

class Detector extends StatefulWidget {
  @override
  _DetectorState createState() => _DetectorState();
}

class _DetectorState extends State<Detector> {
  CameraController _controller;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        FutureBuilder<void>(
          future: initCamera(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ClipRect(
                child: Container(
                  child: Transform.scale(
                    scale: _controller.value.aspectRatio / size.aspectRatio,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: CameraPreview(_controller),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return SpinKitDoubleBounce(color: Colors.blueAccent);
            }
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 25,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.redAccent,
                  padding: EdgeInsets.all(10.0),
                ),
                RawMaterialButton(
                  onPressed: () => takePhoto(),
                  child: Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.blueAccent,
                  padding: EdgeInsets.all(15.0),
                ),
                RawMaterialButton(
                  onPressed: pickImage,
                  child: Icon(
                    Icons.panorama,
                    color: Colors.white,
                    size: 25.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.all(10),
                ),
              ],
            ),
          ),
        ),
      ]
    );
  }

  Future initCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    var backCameras = cameras.where((CameraDescription desc) => desc.lensDirection == CameraLensDirection.back).toList();
    _controller = CameraController(backCameras[0], ResolutionPreset.max);
    await _controller.initialize();
    return;
  }

  Future pickImage() async {
    try {
      File image = await ImagePicker.pickImage(source: ImageSource.gallery);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PictureShow(image: Image.file(image))),
      );
    } on Exception catch (e) {
      ResultHandler
          .showInfoSnackbar(Text("Ein Fehler ist aufgetreten beim Öffnen des Bildes. Die App benötigt Zugriff auf die Galerie"));
    }

  }

  void takePhoto() async {
    final String path = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );
    await _controller.takePicture(path);

    File image = File(path);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PictureShow(image: Image.file(image)), ),
    );
  }
}