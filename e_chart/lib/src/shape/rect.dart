import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class CRect extends CShape {
  double left;
  double top;
  double right;
  double bottom;
  Corner corner;

  CRect({this.left = 0, this.top = 0, this.right = 0, this.bottom = 0, this.corner = Corner.zero});

  CRect.fromCenter({required Offset center, required double width, required double height, this.corner = Corner.zero})
      : left = center.dx - width / 2,
        top = center.dy - height / 2,
        right = center.dx + width / 2,
        bottom = center.dy + height / 2;

  static CRect fromAttr(Attrs attrs) {
    var center = attrs.getCenter() ?? Offset.zero;
    var size = attrs.getSize(const Size(0, 0))!;
    var left = center.dx - size.width / 2;
    var top = center.dy - size.height / 2;

    return CRect(left: left, top: top, right: left + size.width, bottom: top + size.height);
  }

  @override
  Path buildPath() {
    Path path = Path();
    path.addRect(bound);
    return path;
  }

  Offset get center => bound.center;
  Size get size => bound.size;

  @override
  Rect buildBound() {
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  bool contains(Offset offset) => bound.contains2(offset);

  @override
  bool get isClosed => true;

  @override
  void render(Canvas2 canvas, Paint paint, CStyle style) {
    style.drawRect(canvas, paint, bound, corner);
  }

  @override
  void fill(Attrs attr) {}
}

CShape? rectShapeBuilder(LayoutResult value, Size size, Attrs attrs) {
  Corner corner = Corner.fromAttr(attrs);
  if (value is RectLayoutResult) {
    return CRect(left: value.left, top: value.top, right: value.right, bottom: value.bottom, corner: corner);
  }
  if (value is CircleLayoutResult) {
    return CRect.fromCenter(
      center: value.center,
      width: size.width,
      height: size.height,
    );
  }
  if (value is OffsetLayoutResult) {
    return CRect.fromCenter(
      center: Offset(value.x, value.y),
      width: size.width,
      height: size.height,
    );
  }
  if (value is PolarLayoutResult) {
    return CRect.fromCenter(
      center: circlePoint(value.radius, value.angle, value.center),
      width: size.width,
      height: size.height,
    );
  }
  return null;
}
