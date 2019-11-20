import 'dart:math';
import 'dart:ui' as ui;


class MathService {

  double pointDistance(ui.Offset o1, ui.Offset o2) {
    return sqrt(pow(o1.dx - o2.dx, 2) + pow(o1.dy - o2.dy, 2));
  }

  /// Calculate angle for point with law of cosine
  /// @params are just the indeces of the points in the array
  bool calculateAngle(List<ui.Offset> futurePoints, int mainIndex, int beforeIndex, int afterIndex) {
    double a = pointDistance(futurePoints[mainIndex], futurePoints[beforeIndex]);
    double b = pointDistance(futurePoints[mainIndex], futurePoints[afterIndex]);
    double c = pointDistance(futurePoints[afterIndex], futurePoints[beforeIndex]);
    double angle = acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b)) * (180 / pi);
    return angle < 120 && angle > 20;
  }
  
  ui.Offset correctCollisions(ui.Offset point, ui.Rect boundingBox) {
    /// Y Axis collisions
    if (point.dy - boundingBox.top < 0) {
      point = ui.Offset(point.dx, boundingBox.top);
    } else if (point.dy > boundingBox.bottom) {
      point = ui.Offset(point.dx, boundingBox.bottom);
    }
    /// X Axis collisions
    if (point.dx < boundingBox.left) {
      point = ui.Offset(boundingBox.left, point.dy);
    } else if (point.dx > boundingBox.right) {
      point = ui.Offset(boundingBox.right, point.dy);
    }

    return point;
  }

  List<ui.Offset> getStartingPointsForImage(ui.Rect boundingBox, {double rectWidth = 20, double rectHeight = 40}) {
    double dx = boundingBox.left + boundingBox.width / 2;
    double dy = boundingBox.top + boundingBox.height / 2;

    List<ui.Offset> fourPoints = [
      ui.Offset(dx - rectWidth, dy - rectHeight),
      ui.Offset(dx - rectWidth, dy + rectHeight),
      ui.Offset(dx + rectWidth, dy + rectHeight),
      ui.Offset(dx + rectWidth, dy - rectHeight)
    ];

    return fourPoints;
  }

}
final MathService mathService = MathService();