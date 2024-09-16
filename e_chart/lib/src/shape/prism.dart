import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///棱形
class Prism extends CShape {
  Offset center;
  double width;
  double height;

  Prism({
    this.center = const Offset(0, 0),
    this.width = 0,
    this.height = 0,
  });

  @override
  Path buildPath() {
    Path p = Path();
    p.moveTo(center.dx, center.dy - height / 2.0);
    p.lineTo(center.dx + width / 2.0, center.dy);
    p.lineTo(center.dx, center.dy + height / 2.0);
    p.lineTo(center.dx - width / 2.0, center.dy);
    p.close();
    return p;
  }

  @override
  Rect buildBound() {
    return Rect.fromCenter(center: center, width: width, height: height);
  }

  @override
  bool get isClosed => true;

  @override
  void fill(Attrs attr) {}
}

CShape prismShapeBuilder(LayoutResult value, Size size, Attrs attrs) {
  if (value is RectLayoutResult) {
    return Prism(
      center: Offset(value.centerX, value.centerY),
      width: value.right - value.left,
      height: value.bottom - value.top,
    );
  }
  if (value is CircleLayoutResult) {
    return Prism(
      center: value.center,
      width: size.width,
      height: size.height,
    );
  }
  if (value is OffsetLayoutResult) {
    return Prism(
      center: Offset(value.x, value.y),
      width: size.width,
      height: size.height,
    );
  }
  if (value is PolarLayoutResult) {
    return Prism(
      center: circlePoint(value.radius, value.angle, value.center),
      width: size.width,
      height: size.height,
    );
  }
  return EmptyShape();
}
