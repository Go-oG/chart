import 'dart:math';
import 'dart:ui';

class LayoutResult {
  const LayoutResult();
}

class RectLayoutResult extends LayoutResult {
  double left = 0;
  double top = 0;
  double right = 0;
  double bottom = 0;

  RectLayoutResult({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  RectLayoutResult.fromRect(Rect rect) {
    left = rect.left;
    top = rect.top;
    right = rect.right;
    bottom = rect.bottom;
  }

  double get centerX => (left + right) / 2.0;

  double get centerY => (top + bottom) / 2.0;

  double get minSide {
    return min(right - left, bottom - top);
  }
}

class ArcLayoutResult extends LayoutResult {
  Offset center = Offset.zero;
  double innerRadius = 0;
  double outRadius = 0;
  double startAngle = 0;
  double sweepAngle = 0;
  double cornerRadius = 0;
  double padAngle = 0;
  double? maxRadius;
}

class OffsetLayoutResult extends LayoutResult {
  double x = 0;
  double y = 0;

  OffsetLayoutResult({
    this.x = 0,
    this.y = 0,
  });
}

class PolarLayoutResult extends LayoutResult {
  Offset center = Offset.zero;
  double radius = 0;
  double angle = 0;

  PolarLayoutResult({
    this.center = Offset.zero,
    this.radius = 0,
    this.angle = 0,
  });
}

class CircleLayoutResult extends LayoutResult {
  Offset center = Offset.zero;
  double radius = 0;
  bool clockwise = true;
}
