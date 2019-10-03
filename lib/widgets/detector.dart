import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class Detector extends StatefulWidget {
  @override
  _DetectorState createState() => _DetectorState();
}

class _DetectorState extends State<Detector> {
  CameraController _controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<void>(
          future: initCamera(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return SpinKitDoubleBounce(color: Colors.blueAccent);
            }
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () => takePhoto(),
                  child: new Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.blueAccent,
                  padding: const EdgeInsets.all(15.0),
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

  void takePhoto() async {
    final String path = join(
      // Store the picture in the temp directory.
      // Find the temp directory using the `path_provider` plugin.
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );
    await _controller.takePicture(path);
  }
}