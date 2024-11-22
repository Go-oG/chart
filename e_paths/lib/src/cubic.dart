import 'dart:math';
import 'dart:ui';

final class Cubic {
  late final Offset start;
  late final Offset end;
  late final Offset control1;
  late final Offset control2;

  Cubic(this.start, this.end, this.control1, this.control2);

  Cubic.ofLine(this.start, this.end) {
    var offset = start + end;
    control1 = Offset.lerp(start, end, 0.33333)!;
    control2 = Offset.lerp(start, end, 0.66667)!;
  }

  Cubic.ofQuadratic(this.start, this.end, Offset control) {
    control1 = start + (control - start) * 0.666667;
    control2 = end + (control - end) * 0.666667;
  }

  ///所有单位都为弧度
  Cubic.ofArc(
    Rect rect,
    double startAngle,
    double sweepAngle,
    bool forceMoveTo,
  ) {
    final sinA = sin(startAngle);
    final cosA = cos(startAngle);
    final sinE = sin(startAngle + sweepAngle);
    final cosE = cos(startAngle + sweepAngle);

    final a = max(rect.width, rect.height) / 2;
    final b = min(rect.width, rect.height) / 2;

    final center = rect.center;
    final cx = center.dx;
    final cy = center.dy;

    start = Offset(center.dx + a * cosA, center.dy + b * sinA);
    end = Offset(center.dx + a * cosE, center.dy + b * sinE);
    final v = 1.3333333 * tan(sweepAngle * 0.25);
    var c1x = cx + a * cosA - v * b * sinA;
    var c1y = cy + b * sinA + v * a * cosA;
    var c2x = cx + a * cosE + v * b * sinE;
    var c2y = cy + b * sinE - v * a * cosE;

    control1 = Offset(c1x, c1y);
    control2 = Offset(c2x, c2y);
  }

  Cubic.ofArc2(this.start, this.end, Radius radius, double rotation, bool largeArc, bool clockwise) {
    final r = max(radius.x, radius.y);
    double angle = acos((start.dx - end.dx) / (2 * r));
    if (!clockwise) {
      angle = -angle;
    }
    double controlLength = r * 4 / 3 * tan(angle / 4);
    double cosRotation = cos(rotation);
    double sinRotation = sin(rotation);

    control1 = Offset(
      start.dx + controlLength * cosRotation,
      start.dy + controlLength * sinRotation,
    );
    control2 = Offset(
      end.dx - controlLength * cosRotation,
      end.dy - controlLength * sinRotation,
    );
  }

  static List<Cubic> ofOval(Rect rect) {
    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;
    final rx = (right - left) / 2;
    final ry = (bottom - top) / 2;

    final k = 4 / 3 * (sqrt(2) - 1);

    final cubic1 = Cubic(
      Offset(left, top + ry),
      Offset(left + rx, top + ry),
      Offset(left + rx * k, top),
      Offset(left + rx, top + ry * k),
    );
    final cubic2 = Cubic(
      Offset(right - rx, top + ry),
      Offset(right, top),
      Offset(right, top + ry * k),
      Offset(right - rx * k, top),
    );

    final cubic3 = Cubic(
      Offset(right, bottom - ry),
      Offset(right - rx, bottom),
      Offset(right - rx * k, bottom),
      Offset(right - rx, bottom - ry * k),
    );

    final cubic4 = Cubic(
      Offset(left + rx, bottom),
      Offset(left, bottom - ry),
      Offset(left, bottom - ry * k),
      Offset(left + rx * k, bottom),
    );
    return [cubic1, cubic2, cubic3, cubic4];
  }

  static List<Cubic> ofRRect(RRect rect) {
    final k = 1 - sqrt(2) / 2;
    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;

    // 计算四个角的控制点
    var cubic1 = Cubic(
      Offset(left, top + rect.tlRadiusY),
      Offset(left + rect.tlRadiusX, top),
      Offset(left, top + rect.tlRadiusY * k),
      Offset(left + rect.tlRadiusX * k, top),
    );

    final cubic2 = Cubic(
      Offset(right - rect.trRadiusX, top),
      Offset(right, top + rect.trRadiusY),
      Offset(right - rect.trRadiusX * k, top),
      Offset(right, top + rect.trRadiusY * k),
    );

    final cubic3 = Cubic(
      Offset(right, bottom - rect.brRadiusY),
      Offset(right - rect.brRadiusX, bottom),
      Offset(right, bottom - rect.brRadiusY * k),
      Offset(right - rect.brRadiusX * k, bottom),
    );

    final cubic4 = Cubic(
      Offset(left + rect.blRadiusX, bottom),
      Offset(left, bottom - rect.blRadiusY),
      Offset(left + rect.blRadiusX * k, bottom),
      Offset(left, bottom - rect.blRadiusY * k),
    );
    return [
      cubic1,
      Cubic.ofLine(cubic1.end, cubic2.start),
      cubic2,
      Cubic.ofLine(cubic2.end, cubic3.start),
      cubic3,
      Cubic.ofLine(cubic3.end, cubic4.start),
      cubic4,
      Cubic.ofLine(cubic4.end, cubic1.start),
    ];
  }

  @override
  int get hashCode => Object.hash(start, end, control1, control2);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Cubic && other.control1 == control1 && other.start == start && other.end == end;
  }

  static Cubic lerp(Cubic start, Cubic end, double t) {
    final s = Offset.lerp(start.start, end.start, t)!;
    final e = Offset.lerp(start.end, end.end, t)!;
    final c1 = Offset.lerp(start.control1, end.control1, t)!;
    final c2 = Offset.lerp(start.control2, end.control2, t)!;
    return Cubic(s, e, c1, c2);
  }
}
