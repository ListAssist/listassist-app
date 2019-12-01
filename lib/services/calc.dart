import 'dart:math';
import 'dart:ui' as ui;


class CalcService {

  /// Calculates the distance between two points
  double pointDistance(ui.Offset o1, ui.Offset o2) {
    return sqrt(pow(o1.dx - o2.dx, 2) + pow(o1.dy - o2.dy, 2));
  }

  /// Calculate angle for point with law of cosine
  /// @params are just the indeces of the points in the array
  bool checkAngle(List<ui.Offset> futurePoints, int mainIndex, int beforeIndex, int afterIndex) {
    double a = pointDistance(futurePoints[mainIndex], futurePoints[beforeIndex]);
    double b = pointDistance(futurePoints[mainIndex], futurePoints[afterIndex]);
    double c = pointDistance(futurePoints[afterIndex], futurePoints[beforeIndex]);
    double angle = acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b)) * (180 / pi);
    return angle < 120 && angle > 20;
  }

  /// Methods for correcting collisions with boundingBoxes
  /// correct x & y collisions for coordinates
  ui.Offset correctCollisions(ui.Offset point, ui.Rect boundingBox) {
    point = correctXCollision(point, boundingBox);
    point = correctYCollision(point, boundingBox);
    return point;
  }

  ui.Offset correctXCollision(ui.Offset point, ui.Rect boundingBox) {
    /// X Axis collisions
    if (point.dx < boundingBox.left) {
      point = ui.Offset(boundingBox.left, point.dy);
    } else if (point.dx > boundingBox.right) {
      point = ui.Offset(boundingBox.right, point.dy);
    }
    return point;
  }

  ui.Offset correctYCollision(ui.Offset point, ui.Rect boundingBox) {
    /// Y Axis collisions
    if (point.dy - boundingBox.top < 0) {
      point = ui.Offset(point.dx, boundingBox.top);
    } else if (point.dy > boundingBox.bottom) {
      point = ui.Offset(point.dx, boundingBox.bottom);
    }
    return point;
  }

  /// Get middle point between two points
  ui.Offset getMiddlePoint(ui.Offset o1, ui.Offset o2) {
    return ui.Offset((o1.dx + o2.dx) / 2, (o1.dy + o2.dy) / 2);
  }

  /// recalculate all middlepoints for set of points
  List<ui.Offset> recalculateMiddlePoints(List<ui.Offset> points) {
    for(int i = 1; i < points.length; i += 2) {
      points[i] = getMiddlePoint(points[i - 1], points[i + 1 == points.length ? 0 : i + 1]);
    }
    return points;
  }

  /// Check if angles in set of points are valid
  bool checkAngles(List<ui.Offset> points) {
    return
        checkAngle(points, 0, 2, 6) &&
        checkAngle(points, 2, 4, 0) &&
        checkAngle(points, 4, 6, 2) &&
        checkAngle(points, 6, 0, 4);
  }


  /// check if distance between all polygon points is okay
  bool checkDistancesPoints(List<ui.Offset> points, {double minDistance = 60}) {
    for (int i = 0; i < points.length; i += 2) {
      if (i + 2 == points.length) {
        if (pointDistance(points[i], points[0]) < minDistance) return false;
      } else {
        if (pointDistance(points[i], points[i + 2]) < minDistance) return false;
      }
    }
    return true;
  }

  /// calculate starting points for newly picked image
  List<ui.Offset> getStartingPointsForImage(ui.Rect boundingBox, {double rectWidth = 150, double rectHeight = 200, double margin = 4}) {
    double dx = boundingBox.left + boundingBox.width / 2;
    double dy = boundingBox.top + boundingBox.height / 2;
    rectWidth = rectWidth / 2 > boundingBox.width / 2 ? boundingBox.width / 2 - margin: rectWidth / 2;
    rectHeight = rectHeight / 2 > boundingBox.height/ 2 ? boundingBox.height / 2 - margin: rectHeight / 2;

    List<ui.Offset> fourPoints = [
      ui.Offset(dx - rectWidth, dy - rectHeight),
      ui.Offset(dx - rectWidth, dy + rectHeight),
      ui.Offset(dx + rectWidth, dy + rectHeight),
      ui.Offset(dx + rectWidth, dy - rectHeight)
    ];

    List<ui.Offset> allPoints = [
      fourPoints[0], getMiddlePoint(fourPoints[0], fourPoints[1]),
      fourPoints[1], getMiddlePoint(fourPoints[1], fourPoints[2]),
      fourPoints[2], getMiddlePoint(fourPoints[2], fourPoints[3]),
      fourPoints[3], getMiddlePoint(fourPoints[3], fourPoints[0]),
    ];
    return allPoints;
  }

  /// Algorithms for detecting collisions and then moving all other points according to the collision
  List<ui.Offset> correctedPolygonCoordinates(
      List<ui.Offset> points,
      ui.Rect boundingBox,
      ui.Offset movementDelta,
      {bool dx = true, bool dy = true, int fromIndex = 0, int toIndex = -1}
      ) {
    if (toIndex == -1) { toIndex = points.length - 1; }

    /// Check if one point will be out of bound and if size is still okay
    bool hit = false;
    ui.Offset delta;

    /// check for collisions
    for(int i = fromIndex; i <= toIndex; i++) {
      final ui.Offset currentPoint = points[i == points.length ? 0 : i];

      ui.Offset corrected;
      ui.Offset collisionCorrected;
      if (dx && dy) {
        corrected = currentPoint + movementDelta;
        collisionCorrected = calcService.correctCollisions(corrected, boundingBox);
      } else if (dx) {
        corrected = ui.Offset(currentPoint.dx + movementDelta.dx, currentPoint.dy);
        collisionCorrected = calcService.correctXCollision(corrected, boundingBox);
      } else {
        corrected = ui.Offset(currentPoint.dx, currentPoint.dy + movementDelta.dy);
        collisionCorrected = calcService.correctYCollision(corrected, boundingBox);
      }

      if (collisionCorrected != corrected) {
        hit = true;
        delta = collisionCorrected - corrected;
        break;
      }
    }
    /// check if there was a hit, if so update only the small delta which the affected node moved
    for (int i = fromIndex; i <= toIndex; i++) {
      final int realIndex = i == points.length ? 0 : i;

      if (hit) {
        points[realIndex] = points[realIndex] + delta;
      } else if (dx && dy) {
        points[realIndex] += movementDelta;
      } else if (dx) {
        points[realIndex] = ui.Offset(points[realIndex].dx + movementDelta.dx, points[realIndex].dy);
      } else {
        points[realIndex] = ui.Offset(points[realIndex].dx, points[realIndex].dy + movementDelta.dy);
      }
    }

    /// recalculate middle points
    points = calcService.recalculateMiddlePoints(points);

    return points;
  }

  /// export points to be ready for post to server
  List<Map<String, double>> exportPoints(List<ui.Offset> points, ui.Image image, ui.Rect boundingBox) {
    double ratioX = image.width / boundingBox.width;
    double ratioY = image.height / boundingBox.height;
    return points.map((ui.Offset point) {
      return {
        "x": point.dx * ratioX,
        "y": (point.dy - boundingBox.top) * ratioY
      };
    }).toList();
  }
}
final CalcService calcService = CalcService();
