import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PictureShow extends StatefulWidget {
  final Image image;

  PictureShow({Key key, this.image}): super(key: key);

  @override
  _PictureShowState createState() => _PictureShowState();
}

class _PictureShowState extends State<PictureShow> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.image,
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
                    onPressed: () => Navigator.pop(context),
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