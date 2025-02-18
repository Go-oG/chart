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
