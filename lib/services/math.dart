import 'dart:math';
import 'dart:ui' as ui;


class MathService {

  /// Calculate angle for point with law of cosine
  /// @params are just the indeces of the points in the array
  bool calculateAngle(List<ui.Offset> futurePoints, int mainIndex, int beforeIndex, int afterIndex) {
    double a = sqrt(pow(futurePoints[mainIndex].dx - futurePoints[beforeIndex].dx, 2) + pow(futurePoints[mainIndex].dy - futurePoints[beforeIndex].dy, 2));
    double b = sqrt(pow(futurePoints[mainIndex].dx - futurePoints[afterIndex].dx, 2) + pow(futurePoints[mainIndex].dy - futurePoints[afterIndex].dy, 2));
    double c = sqrt(pow(futurePoints[afterIndex].dx - futurePoints[beforeIndex].dx, 2) + pow(futurePoints[afterIndex].dy - futurePoints[beforeIndex].dy, 2));
    double angle = acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b)) * (180 / pi);
    return angle < 120 && angle > 20;
  }
}
final MathService mathService = MathService();