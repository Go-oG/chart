import 'dart:math';
import '../e_shapes.dart';
import 'utils.dart' as utils;

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  Point copy({double? x, double? y}) {
    return Point(x ?? this.x, y ?? this.y);
  }

  double get distance => sqrt(x * x + y * y);

  double get distanceSquared => x * x + y * y;

  double dotProduct(Point other) => x * other.x + y * other.y;

  double dotProduct2(double otherX, double otherY) => x * otherX + y * otherY;

  bool clockwise(Point other) {
    return x * other.y - y * other.x > 0;
  }

  Point get direction {
    final d = distance;
    if (d <= 0) {
      throw "Can't get the direction of a 0-length vector";
    }
    return Point(x / d, y / d);
  }

  Point operator -() {
    return Point(-x, -y);
  }

  Point operator -(Point other) {
    return Point(x - other.x, y - other.y);
  }

  Point operator +(Point other) {
    return Point(x + other.x, y + other.y);
  }

  Point operator *(Point other) {
    return Point(x * other.x, y * other.y);
  }

  Point operator /(Point other) {
    return Point(x / other.x, y / other.y);
  }

  Point div(num other) {
    return Point(x / other, y / other);
  }

  Point mul(num other) {
    return Point(x * other, y * other);
  }

  Point operator %(num operand) {
    return Point(x % operand, y % operand);
  }

  Point transformed(PointTransformer f) {
    var result = f(x, y);
    return Point(result.first, result.second);
  }

  Point rotate90() => Point(-y, x);

  static Point interpolate(Point start, Point stop, double fraction) {
    return Point(utils.interpolate(start.x, stop.x, fraction), utils.interpolate(start.y, stop.y, fraction));
  }
}
