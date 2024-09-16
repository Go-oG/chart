import 'dart:math';
import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

///N角星形图案
class Star extends CShape {
  Offset center;
  late int count;
  num ir;
  num or;
  num angleOffset;

  ///是否朝内 true时为圆内螺线 false 为凸形
  ///且当为 true时,ir将无效
  bool inside;

  Star(
    this.center,
    int count,
    this.ir,
    this.or, {
    this.angleOffset = 0,
    this.inside = false,
  }) {
    if (inside) {
      if (ir <= 0) {
        this.count = 3;
      } else {
        this.count = (or ~/ ir) - 1;
      }
    } else {
      this.count = count;
    }
    if (this.count <= 1) {
      this.count = 5;
    }
  }

  @override
  Path buildPath() {
    return inside ? _buildInsidePath() : _buildOutPath();
  }

  @override
  Rect buildBound() {
    return Rect.fromCircle(center: center, radius: or.toDouble());
  }

  Path _buildInsidePath() {
    Path path = Path();
    for (int i = 0; i <= 360; i++) {
      num a = angleOffset + i;
      a *= angleUnit;
      double x = cos(a) + cos(count * a) / count;
      double y = sin(a) - sin(count * a) / count;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    if (center != Offset.zero) {
      Matrix4 matrix4 = Matrix4.translationValues(-center.dx, -center.dy, 0);
      path.transform(matrix4.storage);
    }
    return path;
  }

  Path _buildOutPath() {
    double offset = 180 / count;
    List<Offset> outPoints = [];
    double rotate = -90 + angleOffset.toDouble();
    for (int i = 0; i < count; i++) {
      double perRad = 360 / count * i;
      outPoints.add(circlePoint(or, perRad + rotate, center));
      outPoints.add(circlePoint(ir, perRad + rotate + offset, center));
    }
    Path p = Path();
    for (int i = 0; i < outPoints.length; i++) {
      var offset = outPoints[i];
      if (i == 0) {
        p.moveTo(offset.dx, offset.dy);
      } else {
        p.lineTo(offset.dx, offset.dy);
      }
    }
    p.close();
    return p;
  }

  @override
  bool get isClosed => true;

  @override
  void fill(Attrs attr) {}

  static Star lerpStar(Star s, Star e, double t) {
    var center = (s.center == e.center) ? e.center : Offset.lerp(s.center, e.center, t)!;
    var count = lerpInt(s.count, e.count, t);
    num ir = lerpDouble(s.ir, e.ir, t)!;
    num or = lerpDouble(s.or, e.or, t)!;
    num angleOffset = lerpDouble(s.angleOffset, e.angleOffset, t)!;
    return Star(center, count, ir, or, angleOffset: angleOffset, inside: e.inside);
  }
}

CShape starShapeBuilder(LayoutResult value, Size size, Attrs attrs) {
  var count = attrs.getInt([Attr.count], 5);
  var or = attrs.getDouble([Attr.outRadius], size.shortestSide / 2);
  var ir = attrs.getDouble([Attr.innerRadius], 0);
  var off = attrs.getDouble([Attr.offset]);
  var inside = attrs.getObject([Attr.inside]);
  if (inside is! bool) {
    inside = false;
  }

  if (value is RectLayoutResult) {
    return Star(
      Offset(value.centerX, value.centerY),
      count,
      ir,
      or,
      inside: inside,
      angleOffset: off,
    );
  }
  if (value is CircleLayoutResult) {
    return Star(
      value.center,
      count,
      ir,
      or,
      inside: inside,
      angleOffset: off,
    );
  }
  if (value is OffsetLayoutResult) {
    return Star(
      Offset(value.x, value.y),
      count,
      ir,
      or,
      inside: inside,
      angleOffset: off,
    );
  }
  if (value is PolarLayoutResult) {
    return Star(
      circlePoint(value.radius, value.angle, value.center),
      count,
      ir,
      or,
      inside: inside,
      angleOffset: off,
    );
  }
  return EmptyShape();
}
