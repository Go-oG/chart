import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class BBox {
  num left;
  num top;
  num width;
  num height;

  BBox(this.left, this.top, this.width, this.height);
}

class Point2 {
  num x;
  num y;

  Point2(this.x, this.y);

  List<num> toList() {
    return [x, y];
  }

  num distance(Point2 other) {
    var dx = x - other.x;
    var dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }
}

class Corner {
  static const zero = Corner(0, 0, 0, 0);
  final double leftTop;
  final double rightTop;
  final double leftBottom;
  final double rightBottom;

  const Corner(this.leftTop, this.rightTop, this.leftBottom, this.rightBottom);

  const Corner.all(double v)
      : leftTop = v,
        rightTop = v,
        leftBottom = v,
        rightBottom = v;

  const Corner.only({
    this.leftTop = 0,
    this.leftBottom = 0,
    this.rightTop = 0,
    this.rightBottom = 0,
  });

  bool get isEmpty => leftTop == 0 && rightTop == 0 && leftBottom == 0 && rightBottom == 0;

  static Corner lerp(Corner s, Corner e, double t) {
    return Corner(
      lerpDouble(s.leftTop, e.leftTop, t)!,
      lerpDouble(s.rightTop, e.rightTop, t)!,
      lerpDouble(s.leftBottom, e.leftBottom, t)!,
      lerpDouble(s.rightBottom, e.rightBottom, t)!,
    );
  }

  @override
  int get hashCode {
    return Object.hash(leftTop, rightTop, leftBottom, rightBottom);
  }

  @override
  bool operator ==(Object other) {
    return other is Corner &&
        other.leftTop.equal(leftTop) &&
        other.rightTop.equal(rightTop) &&
        other.leftBottom.equal(leftBottom) &&
        other.rightBottom.equal(rightBottom);
  }
}

class Offset2 {
  double x;
  double y;

  Offset2(this.x, this.y);

  Offset toOffset() {
    return Offset(x.toDouble(), y.toDouble());
  }

  double distance(Offset2 o2) {
    return toOffset().distance3(o2.x, o2.y);
  }

  double distance2(Offset o2) {
    return o2.distance3(x, y);
  }

  void add(Offset other) {
    x += other.dx;
    y += other.dy;
  }

  void sub(Offset other) {
    x -= other.dx;
    y -= other.dy;
  }

  @override
  String toString() {
    return 'C[${x.toStringAsFixed(0)},${y.toStringAsFixed(0)}]';
  }
}
