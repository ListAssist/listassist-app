import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

import 'package:listassist/widgets/camera-scanner/camera-scanner.dart';


class PolygonPainter extends CustomPainter {
  List<ui.Offset> points;
  bool overflow;
  double radius;

  EditorType currentType;

  ui.Image image;
  static Rect outputSubrect;

  Function callback;

  PolygonPainter({@required this.points, @required this.overflow, @required this.radius, @required this.image, @required this.currentType, @required this.callback});

  @override
  void paint(Canvas canvas, Size size) {
    Color mainColor = overflow ? Color.fromRGBO(52, 152, 219, 0.2) : Color.fromRGBO(231, 76, 60, 0.2);
    /// paint for lines
    final paint = Paint()
      ..color = overflow ? Color.fromRGBO(231, 76, 60, 1) : Color.fromRGBO(52, 152, 219, 1)
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    /// paint for lines
    final imagePaint = Paint();
    /// paint for fill
    final fillPaint = Paint()
      ..color = mainColor
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    /// paint for circle
    final circlePaint = Paint()
      ..color = overflow ? Color.fromRGBO(231, 76, 60, 0.4) : Color.fromRGBO(52, 152, 219, 0.4)
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final outputRect = Rect.fromPoints(ui.Offset.zero, ui.Offset(size.width, size.height));
    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final FittedSizes sizes = applyBoxFit(BoxFit.contain, imageSize, outputRect.size);
    final Rect inputSubrect = Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    /// outputSubrect is the real bounding box for the canvas
    Rect tempOutputSubrect = Alignment.center.inscribe(sizes.destination, outputRect);
    if (PolygonPainter.outputSubrect == null) {
      outputSubrect = tempOutputSubrect;
      callback(tempOutputSubrect);
    } else if (tempOutputSubrect != PolygonPainter.outputSubrect) {
      callback(tempOutputSubrect);
      outputSubrect = tempOutputSubrect;
    }

    canvas.drawImageRect(image, inputSubrect, outputSubrect, imagePaint);

    if (currentType == EditorType.Trainer) {
      for (int i = 0; i < points.length; i++) {
        if (i + 1 == points.length) {
          canvas.drawLine(points[i], points[0], paint);
        } else {
          canvas.drawLine(points[i], points[i + 1], paint);
        }
      }

      int numberCounter = 1;
      for (int i = 0; i < points.length; i++) {
        canvas.drawCircle(points[i], radius, circlePaint);
        if (i % 2 == 0) {
          TextSpan span = TextSpan(style: TextStyle(color: Colors.white), text: numberCounter.toString());
          TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
          tp.layout();
          tp.paint(canvas, Offset(points[i].dx - 3.5, points[i].dy - 8));
          numberCounter++;
        }
      }
    }
  }

  @override
  bool shouldRepaint(PolygonPainter oldPainter) => oldPainter.points != points || overflow ;

}
