import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class Circle extends CShape {
  double radius;
  Offset center;

  Circle({this.center = Offset.zero, this.radius = 0});

  double get x => center.dx;

  double get y => center.dy;

  @override
  bool contains(Offset offset) => offset.inCircle(radius, center: center);

  @override
  bool get isClosed => true;

  @override
  void render(Canvas2 canvas, Paint paint, CStyle style) {
    canvas.drawCircle(center, radius, paint);
  }

  @override
  Path buildPath() {
    var path = Path();
    path.addOval(bound);
    return path;
  }

  @override
  Rect buildBound() {
    return Rect.fromCircle(center: center, radius: radius);
  }

  @override
  void fill(Attrs attr) {}
}

CShape circleShapeBuilder(LayoutResult value, Size size, Attrs attrs) {
  if (value is RectLayoutResult) {
    return Circle(center: Offset(value.centerX, value.centerY), radius: value.minSide / 2);
  }
  if (value is CircleLayoutResult) {
    return Circle(center: value.center, radius: value.radius);
  }
  if (value is OffsetLayoutResult) {
    return Circle(center: Offset(value.x, value.y), radius: size.shortestSide / 2);
  }
  if (value is PolarLayoutResult) {
    return Circle(center: circlePoint(value.radius, value.angle, value.center), radius: size.shortestSide / 2);
  }
  if (value is ArcLayoutResult) {
    return Circle(center: circlePoint(value.outRadius, value.startAngle, value.center), radius: size.shortestSide / 2);
  }

  return EmptyShape();
}
