import 'dart:math';
import 'dart:ui';

final class Cubic {
  final Offset start;
  final Offset end;
  final Offset c1;
  final Offset c2;
  double _length = -1;

  Cubic({required this.start, required this.end, required this.c1, required this.c2});

  @override
  int get hashCode => Object.hash(start, end, c1, c2);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Cubic && other.c1 == c1 && other.start == start && other.end == end;
  }

  static Cubic ofLine(Offset start, Offset end) {
    return Cubic(start: start, end: end, c1: Offset.lerp(start, end, 0.33333)!, c2: Offset.lerp(start, end, 0.66667)!);
  }

  static Cubic ofQuadratic(Offset start, Offset end, Offset control) {
    final control1 = start + (control - start) * 0.666667;
    final control2 = end + (control - end) * 0.666667;
    return Cubic(start: start, end: end, c1: control1, c2: control2);
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
    return Cubic(start: start, end: end, c1: control1, c2: control2);
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
    return Cubic(start: start, end: end, c1: control1, c2: control2);
  }

  static List<Cubic> ofOval(Rect rect) {
    const k = 0.5522847498;

    // 四个顶点
    final p1 = rect.centerRight;
    final p2 = rect.bottomCenter;
    final p3 = rect.centerLeft;
    final p4 = rect.topCenter;

    final tx = rect.center.dx;
    final ty = rect.center.dy;

    final a = rect.width / 2;
    final b = rect.height / 2;

    // 贝塞尔曲线控制点
    final cp1 = Offset(tx + a, ty + k * b); // (a, k * b)
    final cp2 = Offset(tx + k * a, ty + b); // (k * a, b)

    final cp3 = Offset(tx - k * a, ty + b); // (-k * a, b)
    final cp4 = Offset(tx - a, ty + k * b); // (-a, k * b)

    final cp5 = Offset(tx - a, ty - k * b); // (-a, -k * b)
    final cp6 = Offset(tx - k * a, ty - b); // (-k * a, -b)

    final cp7 = Offset(tx + k * a, ty - b); // (k * a, -b)
    final cp8 = Offset(tx + a, ty - k * b); // (a, -k * b)

    final cubic1 = Cubic(start: p1, end: p2, c1: cp1, c2: cp2);
    final cubic2 = Cubic(start: p2, end: p3, c1: cp3, c2: cp4);
    final cubic3 = Cubic(start: p3, end: p4, c1: cp5, c2: cp6);
    final cubic4 = Cubic(start: p4, end: p1, c1: cp7, c2: cp8);

    return [
      cubic4,
      cubic1,
      cubic2,
      cubic3,
    ];
  }

  static List<Cubic> ofRRect(RRect rect) {
    final k = 1 - sqrt(2) / 2;
    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;

    // 计算四个角的控制点
    var cubic1 = Cubic(
      start: Offset(left, top + rect.tlRadiusY),
      end: Offset(left + rect.tlRadiusX, top),
      c1: Offset(left, top + rect.tlRadiusY * k),
      c2: Offset(left + rect.tlRadiusX * k, top),
    );

    final cubic2 = Cubic(
      start: Offset(right - rect.trRadiusX, top),
      end: Offset(right, top + rect.trRadiusY),
      c1: Offset(right - rect.trRadiusX * k, top),
      c2: Offset(right, top + rect.trRadiusY * k),
    );

    final cubic3 = Cubic(
      start: Offset(right, bottom - rect.brRadiusY),
      end: Offset(right - rect.brRadiusX, bottom),
      c1: Offset(right, bottom - rect.brRadiusY * k),
      c2: Offset(right - rect.brRadiusX * k, bottom),
    );

    final cubic4 = Cubic(
      start: Offset(left + rect.blRadiusX, bottom),
      end: Offset(left, bottom - rect.blRadiusY),
      c1: Offset(left + rect.blRadiusX * k, bottom),
      c2: Offset(left, bottom - rect.blRadiusY * k),
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
    final c1 = Offset.lerp(start.c1, end.c1, t)!;
    final c2 = Offset.lerp(start.c2, end.c2, t)!;
    return Cubic(start: s, end: e, c1: c1, c2: c2);
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
    return start * uuu + c1 * (3 * uu * t) + c2 * (3 * u * tt) + end * ttt;
  }

  //在参数t处将曲线分割为两段(De Casteljau算法)
  (Cubic, Cubic) splitAtT(double t) {
    final p01 = start + (c1 - start) * t;
    final p12 = c1 + (c2 - c1) * t;
    final p23 = c2 + (end - c2) * t;

    final p012 = p01 + (p12 - p01) * t;
    final p123 = p12 + (p23 - p12) * t;

    final p0123 = p012 + (p123 - p012) * t;
    final left = Cubic(start: start, end: p0123, c1: p01, c2: p012);
    final right = Cubic(start: p0123, end: end, c1: p123, c2: p23);
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
    var d4 = (end - cubic.end).distance;
    return d1 + d4;
  }

  bool get isLine {
    double cross(Offset p0, Offset p1) {
      return (p0.dx * p1.dy - p0.dy * p1.dx);
    }

    final v1 = c1 - start;
    final v2 = c2 - start;
    final v3 = end - start;
    double cross1 = cross(v1, v2);
    double cross2 = cross(v1, v3);
    return (cross1 - cross2).abs() <= 0.000000001 && cross1.abs() <= 0.000000001;
  }
}
