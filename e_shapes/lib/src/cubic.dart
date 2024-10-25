import 'dart:math' as m;

import 'package:flutter/foundation.dart';

import '../e_shapes.dart';
import 'features.dart';
import 'point.dart';
import 'utils.dart' as utils;

class Cubic {
  static const distanceEpsilon = 2e-53;

  late List<double> points;

  Cubic(
    double anchor0X,
    double anchor0Y,
    double control0X,
    double control0Y,
    double control1X,
    double control1Y,
    double anchor1X,
    double anchor1Y,
  ) {
    points = [anchor0X, anchor0Y, control0X, control0Y, control1X, control1Y, anchor1X, anchor1Y];
  }

  Cubic.fromList(this.points) {
    if (points.length != 8) {
      throw "Points array size should be 8";
    }
  }

  Cubic.of(Point anchor0, Point control0, Point control1, Point anchor1) {
    points = [anchor0.x, anchor0.y, control0.x, control0.y, control1.x, control1.y, anchor1.x, anchor1.y];
  }

  double get anchor0X => points[0];

  double get anchor0Y => points[1];

  double get control0X => points[2];

  double get control0Y => points[3];

  double get control1X => points[4];

  double get control1Y => points[5];

  double get anchor1X => points[6];

  double get anchor1Y => points[7];

  Point pointOnCurve(double t) {
    var u = 1 - t;
    return Point(
        anchor0X * (u * u * u) + control0X * (3 * t * u * u) + control1X * (3 * t * t * u) + anchor1X * (t * t * t),
        anchor0Y * (u * u * u) + control0Y * (3 * t * u * u) + control1Y * (3 * t * t * u) + anchor1Y * (t * t * t));
  }

  bool zeroLength() {
    return (anchor0X - anchor1X).abs() < distanceEpsilon && (anchor0Y - anchor1Y).abs() < distanceEpsilon;
  }

  bool convexTo(Cubic next) {
    var prevVertex = Point(anchor0X, anchor0Y);
    var currVertex = Point(anchor1X, anchor1Y);
    var nextVertex = Point(next.anchor1X, next.anchor1Y);
    return utils.convex(prevVertex, currVertex, nextVertex);
  }

  bool zeroIsh(double value) => (value).abs() < distanceEpsilon;

  void calculateBounds([List<double>? bounds, bool approximate = false]) {
    bounds ??= List.filled(4, 0);
    if (zeroLength()) {
      bounds[0] = anchor0X;
      bounds[1] = anchor0Y;
      bounds[2] = anchor0X;
      bounds[3] = anchor0Y;
      return;
    }
    var minX = m.min(anchor0X, anchor1X);
    var minY = m.min(anchor0Y, anchor1Y);
    var maxX = m.max(anchor0X, anchor1X);
    var maxY = m.max(anchor0Y, anchor1Y);
    if (approximate) {
      bounds[0] = m.min(minX, m.min(control0X, control1X));
      bounds[1] = m.min(minY, m.min(control0Y, control1Y));
      bounds[2] = m.max(maxX, m.max(control0X, control1X));
      bounds[3] = m.max(maxY, m.max(control0Y, control1Y));
      return;
    }
    var xa = -anchor0X + 3 * control0X - 3 * control1X + anchor1X;
    var xb = 2 * anchor0X - 4 * control0X + 2 * control1X;
    var xc = -anchor0X + control0X;
    if (zeroIsh(xa)) {
      if (xb != 0) {
        var t = 2 * xc / (-2 * xb);
        if (t >= 0 && t <= 1) {
          var p = pointOnCurve(t).x;
          if (p < minX) {
            minX = p;
          }
          if (p > maxX) {
            maxX = p;
          }
        }
      }
    } else {
      var xs = xb * xb - 4 * xa * xc;
      if (xs >= 0) {
        var t1 = (-xb + m.sqrt(xs)) / (2 * xa);
        if (t1 >= 0 && t1 <= 1) {
          var p = pointOnCurve(t1).x;
          minX = m.min(minX, p);
          maxX = m.max(maxX, p);
        }
        var t2 = (-xb - m.sqrt(xs)) / (2 * xa);
        if (t2 >= 0 && t2 <= 1) {
          var p = pointOnCurve(t2).x;
          minX = m.min(minX, p);
          maxX = m.max(maxX, p);
        }
      }
    }

    var ya = -anchor0Y + 3 * control0Y - 3 * control1Y + anchor1Y;
    var yb = 2 * anchor0Y - 4 * control0Y + 2 * control1Y;
    var yc = -anchor0Y + control0Y;
    if (zeroIsh(ya)) {
      if (yb != 0) {
        var t = 2 * yc / (-2 * yb);
        if (t >= 0 && t <= 1) {
          var p = pointOnCurve(t).y;
          minY = m.min(minY, p);
          maxY = m.max(maxY, p);
        }
      }
    } else {
      var ys = yb * yb - 4 * ya * yc;
      if (ys >= 0) {
        var t1 = (-yb + m.sqrt(ys)) / (2 * ya);
        if (t1 >= 0 && t1 <= 1) {
          var p = pointOnCurve(t1).y;
          minY = m.min(minY, p);
          maxY = m.max(maxY, p);
        }

        var t2 = (-yb - m.sqrt(ys)) / (2 * ya);
        if (t2 >= 0 && t2 <= 1) {
          var p = pointOnCurve(t2).y;
          minY = m.min(minY, p);
          maxY = m.max(maxY, p);
        }
      }
    }
    bounds[0] = minX;
    bounds[1] = minY;
    bounds[2] = maxX;
    bounds[3] = maxY;
  }

  List<Cubic> split(double t) {
    var u = 1 - t;
    var pointOnCurve = this.pointOnCurve(t);
    var a = Cubic(
        anchor0X,
        anchor0Y,
        anchor0X * u + control0X * t,
        anchor0Y * u + control0Y * t,
        anchor0X * (u * u) + control0X * (2 * u * t) + control1X * (t * t),
        anchor0Y * (u * u) + control0Y * (2 * u * t) + control1Y * (t * t),
        pointOnCurve.x,
        pointOnCurve.y);

    var b = Cubic(
        pointOnCurve.x,
        pointOnCurve.y,
        control0X * (u * u) + control1X * (2 * u * t) + anchor1X * (t * t),
        control0Y * (u * u) + control1Y * (2 * u * t) + anchor1Y * (t * t),
        control1X * u + anchor1X * t,
        control1Y * u + anchor1Y * t,
        anchor1X,
        anchor1Y);
    return [a, b];
  }

  Cubic get reverse => Cubic(anchor1X, anchor1Y, control1X, control1Y, control0X, control0Y, anchor0X, anchor0Y);

  Cubic operator +(Cubic o) {
    List<double> fl = [];
    for (int i = 0; i < 8; i++) {
      fl.add(points[i] + o.points[i]);
    }
    return Cubic.fromList(fl);
  }

  Cubic operator *(num x) {
    return Cubic.fromList(points.map((e) => e * x).toList());
  }

  Cubic operator /(num x) => this * (1.0 / x);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Cubic && listEquals(other.points, points);
  }

  @override
  int get hashCode => Object.hashAll(points);

  Cubic transformed(PointTransformer f) {
    var newCubic = MutableCubic.fromList(points.toList());
    newCubic.transform(f);
    return newCubic;
  }

  static Cubic straightLine(double x0, double y0, double x1, double y1) {
    return Cubic(x0, y0, utils.interpolate(x0, x1, 1 / 3), utils.interpolate(y0, y1, 1 / 3),
        utils.interpolate(x0, x1, 2 / 3), utils.interpolate(y0, y1, 2 / 3), x1, y1);
  }

  static Cubic circularArc(double centerX, double centerY, double x0, double y0, double x1, double y1) {
    var p0d = utils.directionVector(x0 - centerX, y0 - centerY);
    var p1d = utils.directionVector(x1 - centerX, y1 - centerY);
    var rotatedP0 = p0d.rotate90();
    var rotatedP1 = p1d.rotate90();
    var clockwise = rotatedP0.dotProduct2(x1 - centerX, y1 - centerY) >= 0;
    var cosa = p0d.dotProduct(p1d);
    if (cosa > 0.999) {
      return straightLine(x0, y0, x1, y1);
    }
    var k = utils.distance(x0 - centerX, y0 - centerY) *
        4 /
        3 *
        (m.sqrt(2 * (1 - cosa)) - m.sqrt(1 - cosa * cosa)) /
        (1 - cosa) *
        (clockwise ? 1 : -1);
    return Cubic(
        x0, y0, x0 + rotatedP0.x * k, y0 + rotatedP0.y * k, x1 - rotatedP1.x * k, y1 - rotatedP1.y * k, x1, y1);
  }

  static Cubic empty(double x0, double y0) => Cubic(x0, y0, x0, y0, x0, y0, x0, y0);

  Feature asFeature(Cubic next) {
    return straightIsh() ? Edge([this]) : Corner([this], convexTo(next));
  }

  bool straightIsh() {
    return !zeroLength() &&
        utils.collinearIsh(
            anchor0X, anchor0Y, anchor1X, anchor1Y, control0X, control0Y, utils.relaxedDistanceEpsilon) &&
        utils.collinearIsh(anchor0X, anchor0Y, anchor1X, anchor1Y, control1X, control1Y, utils.relaxedDistanceEpsilon);
  }

  bool smoothesIntoIsh(Cubic next) {
    return utils.collinearIsh(
        control1X, control1Y, next.control0X, next.control0Y, anchor1X, anchor1Y, utils.relaxedDistanceEpsilon);
  }

  bool alignsIshWith(Cubic next) {
    return straightIsh() && next.straightIsh() && smoothesIntoIsh(next) || zeroLength() || next.zeroLength();
  }

  static Cubic extend(Cubic a, Cubic b) {
    if (a.zeroLength()) {
      return Cubic(a.anchor0X, a.anchor0Y, b.control0X, b.control0Y, b.control1X, b.control1Y, b.anchor1X, b.anchor1Y);
    }
    return Cubic(a.anchor0X, a.anchor0Y, a.control0X, a.control0Y, a.control1X, a.control1Y, b.anchor1X, b.anchor1Y);
  }
}

class MutableCubic extends Cubic {
  MutableCubic() : super.fromList([]);

  MutableCubic.fromList(super.points) : super.fromList();

  void transformOnePoint(PointTransformer f, int ix) {
    var result = f.call(points[ix], points[ix + 1]);
    points[ix] = result.first;
    points[ix + 1] = result.second;
  }

  void transform(PointTransformer f) {
    transformOnePoint(f, 0);
    transformOnePoint(f, 2);
    transformOnePoint(f, 4);
    transformOnePoint(f, 6);
  }

  void interpolate(Cubic c1, Cubic c2, double progress) {
    for (int i = 0; i < 8; i++) {
      points[i] = utils.interpolate(c1.points[i], c2.points[i], progress);
    }
  }
}
