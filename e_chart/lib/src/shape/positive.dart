import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///正多边形
class PositiveShape extends CShape {
  Offset center;
  double r;
  int count;
  num angleOffset;

  PositiveShape({
    this.center = Offset.zero,
    this.r = 16,
    this.count = 3,
    this.angleOffset = 0,
  });

  @override
  Path buildPath() {
    Path path = Path();
    if (count <= 0 || r <= 0) {
      return path;
    }
    double singleAngle = 360 / count;
    for (int j = 0; j < count; j++) {
      num angle = angleOffset + j * singleAngle;
      Offset c = circlePoint(r, angle, center);
      if (j == 0) {
        path.moveTo(c.dx, c.dy);
      } else {
        path.lineTo(c.dx, c.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  Rect buildBound() => Rect.fromCircle(center: center, radius: r);

  List<Offset> toList() {
    if (count <= 0 || r <= 0) {
      return [];
    }
    List<Offset> ol = [];
    double singleAngle = 360 / count;
    for (int j = 0; j < count; j++) {
      num angle = angleOffset + j * singleAngle;
      Offset c = circlePoint(r, angle, center);
      ol.add(c);
    }
    return ol;
  }

  PositiveShape copy({Offset? center, num? r, int? count, num? angleOffset}) {
    return PositiveShape(
      center: center ?? this.center,
      r: r?.toDouble() ?? this.r,
      count: count ?? this.count,
      angleOffset: angleOffset ?? this.angleOffset,
    );
  }

  @override
  bool contains(Offset offset) {
    return path.contains(offset);
  }

  @override
  bool get isClosed => true;

  @override
  void fill(Attrs attr) {}
}

PositiveShape lerpPositive(PositiveShape s, PositiveShape e, double t) {
  var c = Offset.lerp(s.center, e.center, t)!;
  var r = lerpDouble(s.r, e.r, t)!;
  var angle = lerpDouble(s.angleOffset, e.angleOffset, t)!;
  var count = lerpInt(s.count, e.count, t);
  return PositiveShape(count: count, center: c, r: r, angleOffset: angle);
}

CShape? positiveShapeBuilder(LayoutResult value, Size size, Attrs attrs) {
  int count = attrs.getInt([Attr.count], 4);
  num angleOffset = attrs.getNum([Attr.angleOffset], 0);

  if (value is RectLayoutResult) {
    return PositiveShape(
      center: Offset(value.centerX, value.centerY),
      r: value.minSide / 2,
      count: count,
      angleOffset: angleOffset,
    );
  }
  if (value is CircleLayoutResult) {
    return PositiveShape(
      center: value.center,
      r: size.shortestSide / 2,
      count: count,
      angleOffset: angleOffset,
    );
  }
  if (value is OffsetLayoutResult) {
    return PositiveShape(
      center: Offset(value.x, value.y),
      r: size.shortestSide / 2,
      count: count,
      angleOffset: angleOffset,
    );
  }
  if (value is PolarLayoutResult) {
    return PositiveShape(
      center: circlePoint(value.radius, value.angle, value.center),
      r: size.shortestSide / 2,
      count: count,
      angleOffset: angleOffset,
    );
  }
  return null;
}
