import 'dart:math' as m;
import 'dart:ui';

import '../e_shapes.dart';
import 'point.dart';

const distanceEpsilon = 1e-4;
const angleEpsilon = 1e-6;
const relaxedDistanceEpsilon = 5e-3;
const twoPi = 2 * m.pi;

double distance(double x, double y) => m.sqrt(x * x + y * y);

double distanceSquared(double x, double y) => x * x + y * y;

Point directionVector(double x, double y) {
  var d = distance(x, y);
  if (d <= 0) {
    throw "Required distance greater than zero";
  }
  return Point(x / d, y / d);
}

Point directionVector2(double angleRadians) => Point(m.cos(angleRadians), m.sin(angleRadians));

Point radialToCartesian(double radius, double angleRadians, [Offset center = const Offset(0, 0)]) =>
    directionVector2(angleRadians).mul(radius) + Point(center.dx, center.dy);

double square(double x) => x * x;

double interpolate(double start, double stop, double fraction) {
  return (1 - fraction) * start + fraction * stop;
}

double positiveModulo(double num, double mod) => (num % mod + mod) % mod;

/// Returns whether C is on the line defined by the two points AB
bool collinearIsh(double aX, double aY, double bX, double bY, double cX, double cY,
    [double tolerance = distanceEpsilon]) {
  var ab = Point(bX - aX, bY - aY).rotate90();
  var ac = Point(cX - aX, cY - aY);
  var dotProduct = (ab.dotProduct(ac)).abs();
  var relativeTolerance = tolerance * ab.distance * ac.distance;
  return dotProduct < tolerance || dotProduct < relativeTolerance;
}

bool convex(Point previous, Point current, Point next) {
  return (current - previous).clockwise(next - current);
}

double findMinimum(double v0, double v1, FindMinimumFunction f, [double tolerance = 1e-3]) {
  var a = v0;
  var b = v1;
  while (b - a > tolerance) {
    var c1 = (2 * a + b) / 3;
    var c2 = (2 * b + a) / 3;
    if (f.call(c1) < f.call(c2)) {
      b = c2;
    } else {
      a = c1;
    }
  }
  return (a + b) / 2;
}

Path toPath(Path path, List<Cubic> cubics) {
  path.reset();
  bool first = true;
  for (int i = 0, n = cubics.length; i < n; ++i) {
    Cubic cubic = cubics[i];
    if (first) {
      path.moveTo(cubic.anchor0X, cubic.anchor0Y);
      first = false;
    }
    path.cubicTo(cubic.control0X, cubic.control0Y, cubic.control1X, cubic.control1Y, cubic.anchor1X, cubic.anchor1Y);
  }
  path.close();
  return path;
}

typedef FindMinimumFunction = double Function(double v);

extension NumberExt on num {
  num coerceAtLeast(num v) {
    if (this < v) {
      return v;
    }
    return this;
  }
}
