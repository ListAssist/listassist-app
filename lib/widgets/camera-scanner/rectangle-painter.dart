

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

import 'package:listassist/widgets/camera-scanner/camera-scanner.dart';


class RectanglePainter extends CustomPainter {
  List<ui.Offset> points;
  bool angleOverflow;

  EditorType currentType;

  ui.Image image;
  static Rect outputSubrect;

  Function callback;

  RectanglePainter({@required this.points, @required this.angleOverflow, @required this.image, @required this.currentType, @required this.callback});

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
    Rect tempOutputSubrect = Alignment.center.inscribe(sizes.destination, outputRect);
    if (RectanglePainter.outputSubrect == null) {
      outputSubrect = tempOutputSubrect;
    } else if (tempOutputSubrect != RectanglePainter.outputSubrect) {
      callback(tempOutputSubrect);
      outputSubrect = tempOutputSubrect;
    }

    canvas.drawImageRect(image, inputSubrect, outputSubrect, paint);

    if (currentType == EditorType.Trainer) {
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
  }

  @override
  bool shouldRepaint(RectanglePainter oldPainter) => oldPainter.points != points || angleOverflow ;

}
