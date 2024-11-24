import 'dart:math';
import 'dart:ui';

final class Cubic {
  final Offset start;
  final Offset end;
  final Offset control1;
  final Offset control2;
  double _length = -1;

  Cubic(this.start, this.end, this.control1, this.control2);

  @override
  int get hashCode => Object.hash(start, end, control1, control2);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Cubic && other.control1 == control1 && other.start == start && other.end == end;
  }

  static Cubic ofLine(Offset start, Offset end) {
    return Cubic(start, end, Offset.lerp(start, end, 0.33333)!, Offset.lerp(start, end, 0.66667)!);
  }

  static Cubic ofQuadratic(Offset start, Offset end, Offset control) {
    final control1 = start + (control - start) * 0.666667;
    final control2 = end + (control - end) * 0.666667;
    return Cubic(start, end, control1, control2);
  }

  ///所有单位都为弧度
  static Cubic ofArc(Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    final sinA = sin(startAngle);
    final cosA = cos(startAngle);
    final sinE = sin(startAngle + sweepAngle);
    final cosE = cos(startAngle + sweepAngle);

    final a = max(rect.width, rect.height) / 2;
    final b = min(rect.width, rect.height) / 2;

    final center = rect.center;
    final cx = center.dx;
    final cy = center.dy;

    final start = Offset(center.dx + a * cosA, center.dy + b * sinA);
    final end = Offset(center.dx + a * cosE, center.dy + b * sinE);
    final v = 1.3333333 * tan(sweepAngle * 0.25);
    var c1x = cx + a * cosA - v * b * sinA;
    var c1y = cy + b * sinA + v * a * cosA;
    var c2x = cx + a * cosE + v * b * sinE;
    var c2y = cy + b * sinE - v * a * cosE;

    final control1 = Offset(c1x, c1y);
    final control2 = Offset(c2x, c2y);
    return Cubic(start, end, control1, control2);
  }

  static Cubic ofArc2(Offset start, Offset end, Radius radius, double rotation, bool largeArc, bool clockwise) {
    final r = max(radius.x, radius.y);
    double angle = acos((start.dx - end.dx) / (2 * r));
    if (!clockwise) {
      angle = -angle;
    }
    double controlLength = r * 4 / 3 * tan(angle / 4);
    double cosRotation = cos(rotation);
    double sinRotation = sin(rotation);

    final control1 = Offset(
      start.dx + controlLength * cosRotation,
      start.dy + controlLength * sinRotation,
    );
    final control2 = Offset(
      end.dx - controlLength * cosRotation,
      end.dy - controlLength * sinRotation,
    );
    return Cubic(start, end, control1, control2);
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

  static Cubic lerp(Cubic start, Cubic end, double t) {
    final s = Offset.lerp(start.start, end.start, t)!;
    final e = Offset.lerp(start.end, end.end, t)!;
    final c1 = Offset.lerp(start.control1, end.control1, t)!;
    final c2 = Offset.lerp(start.control2, end.control2, t)!;
    return Cubic(s, e, c1, c2);
  }

  /// 计算贝塞尔曲线上参数t处的点
  Offset getPoint(double t) {
    if (t < 0 || t > 1) {
      throw "t must in [0,1]";
    }
    final tt = t * t;
    final ttt = tt * t;
    final u = 1 - t;
    final uu = u * u;
    final uuu = uu * u;
    return start * uuu + control1 * (3 * uu * t) + control2 * (3 * u * tt) + end * ttt;
  }

  //在参数t处将曲线分割为两段(De Casteljau算法)
  (Cubic, Cubic) splitAtT(double t) {
    final p01 = start + (control1 - start) * t;
    final p12 = control1 + (control2 - control1) * t;
    final p23 = control2 + (end - control2) * t;

    final p012 = p01 + (p12 - p01) * t;
    final p123 = p12 + (p23 - p12) * t;

    final p0123 = p012 + (p123 - p012) * t;
    final left = Cubic(start, p0123, p01, p012);
    final right = Cubic(p0123, end, p123, p23);
    return (left, right);
  }

  // 将曲线均匀分割为n段
  List<Cubic> splitParts(int n) {
    if (n <= 0) throw ArgumentError('分割段数必须大于0');
    if (n == 1) return [this];

    final result = <Cubic>[];
    Cubic currentCurve = this;
    for (var i = 0; i < n - 1; i++) {
      final t = 1.0 / (n - i);
      final (left, right) = currentCurve.splitAtT(t);
      result.add(left);
      currentCurve = right;
    }
    result.add(currentCurve);
    return result;
  }

  ///通过分段线性近似法求曲线长度
  ///参数[numSegments] 越大，结果越精准
  double length([int numSegments = 1000]) {
    if (_length >= 0) {
      return _length;
    }
    double length = 0.0;
    Offset previousPoint = start;
    for (int i = 1; i <= numSegments; i++) {
      double t = i / numSegments;
      Offset currentPoint = getPoint(t);
      length += (currentPoint - previousPoint).distance;
      previousPoint = currentPoint;
    }
    _length = length;
    return length;
  }

  ///(更精确的求长度,高斯求解)
  double length2() {
    if (_length >= 0) {
      return _length;
    }
    const List<double> tValues = [
      -0.9681602395076261,
      -0.8360311073266358,
      -0.6133714327005904,
      -0.3242534234038089,
      0,
      0.3242534234038089,
      0.6133714327005904,
      0.8360311073266358,
      0.9681602395076261,
    ];
    const List<double> weights = [
      0.0812743883615744,
      0.1806481606948574,
      0.2606106964029354,
      0.3123470770400029,
      0.3302393550012598,
      0.3123470770400029,
      0.2606106964029354,
      0.1806481606948574,
      0.0812743883615744
    ];
    double length = 0.0;
    for (int i = 0; i < tValues.length; i++) {
      double t = 0.5 * (1 + tValues[i]);
      Offset dBdt = getPoint(t);
      length += weights[i] * dBdt.distance;
    }
    _length = 0.5 * length;
    return _length;
  }

  void cleanLength() {
    _length = -1;
  }

  ///计算和另一条曲线的相似度
  double computeSimilarity(Cubic cubic) {
    var d1 = (start - cubic.start).distance;
    var d2 = (control1 - cubic.control1).distance;
    var d3 = (control2 - cubic.control2).distance;
    var d4 = (end - cubic.end).distance;
    return d1 + d2 + d3 + d4;
  }



}
