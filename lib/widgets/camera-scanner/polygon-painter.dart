import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

import 'package:listassist/widgets/camera-scanner/camera-scanner.dart';


class PolygonPainter extends CustomPainter {
  List<ui.Offset> points;
  bool overflow;
  double radius;

  EditorType currentType;
  ui.Image image;

  Rect boundingBox;
  Rect inputRect;

  PolygonPainter({
    @required this.points,
    @required this.overflow,
    @required this.radius,
    @required this.image,
    @required this.currentType,
    @required this.boundingBox,
    @required this.inputRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (inputRect != null && boundingBox != null) {
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

      canvas.drawImageRect(image, inputRect, boundingBox, imagePaint);

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
  }

  @override
  bool shouldRepaint(PolygonPainter oldPainter) => oldPainter.points != points || overflow;

}
