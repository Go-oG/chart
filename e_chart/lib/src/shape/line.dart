import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class Line extends CShape {
  List<Offset> pointList = [];
  num smooth;
  List<num>? dashList;
  num disDiff;

  Line(
    this.pointList, {
    this.smooth = 0,
    List<num>? dashList,
    this.disDiff = 2,
  });

  @override
  Path buildPath() {
    Path path;
    if (smooth > 0) {
      path = _smooth();
    } else {
      path = Path();
      Offset first = pointList.first;
      path.moveTo(first.dx, first.dy);
      for (int i = 1; i < pointList.length; i++) {
        Offset p = pointList[i];
        path.lineTo(p.dx, p.dy);
      }
    }

    var dl = dashList;
    if (dl != null && dl.isNotEmpty) {
      path = path.dashPath(dl);
    }
    return path;
  }

  ///返回平滑曲线路径(返回的路径是未封闭的)
  Path _smooth() {
    Path path = Path();
    if (pointList.isEmpty) {
      return path;
    }
    Offset firstPoint = pointList.first;
    path.moveTo(firstPoint.dx, firstPoint.dy);
    for (int i = 0; i < pointList.length - 1; i++) {
      Offset cur = pointList[i];
      Offset next = pointList[i + 1];
      List<Offset> cl = _getCtrPoint(cur, next);

      if (cl.length != 2) {
        path.lineTo(next.dx, next.dy);
      } else {
        var c1 = cl[0];
        var c2 = cl[1];
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, next.dx, next.dy);
      }
    }
    return path;
  }

  ///获取贝塞尔曲线控制点
  List<Offset> _getCtrPoint(Offset start, Offset end) {
    var v = smooth;
    if (start.dx == end.dx || start.dy == end.dy) {
      return [];
    }
    double dx = end.dx - start.dx;
    return [
      Offset(start.dx + dx * v, start.dy),
      Offset(end.dx - dx * v, end.dy),
    ];
  }

  @override
  bool contains(Offset offset) {
    Path path = this.path;
    if (path.contains(offset)) {
      return true;
    }
    PathMetrics metrics = path.computeMetrics();
    for (PathMetric metric in metrics) {
      double i = 0;
      while (i < metric.length) {
        Tangent? tangent = metric.getTangentForOffset(i);
        if (tangent != null) {
          Offset p = tangent.position;
          if (offset.distance2(p) <= disDiff) {
            return true;
          }
        }
        i++;
      }
    }
    return false;
  }

  ///将该段线条追加到Path的后面
  void appendToPathEnd(Path path) {
    if (pointList.isEmpty) {
      return;
    }
    Offset firstPoint = pointList.first;
    path.lineTo(firstPoint.dx, firstPoint.dy);
    for (int i = 0; i < pointList.length - 1; i++) {
      Offset cur = pointList[i];
      Offset next = pointList[i + 1];
      List<Offset> cl = _getCtrPoint(cur, next);
      if (cl.length != 2) {
        path.lineTo(next.dx, next.dy);
      } else {
        var c1 = cl[0];
        var c2 = cl[1];
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, next.dx, next.dy);
      }
    }
  }

  @override
  bool get isClosed => false;

  /// 返回其 step图形样式坐标点
  static List<Offset> step(List<Offset> points, [double ratio = 0.5, Direction dir = Direction.horizontal]) {
    return step2(points, LineType(ratio), dir);
  }

  static List<Offset> step2(List<Offset> points,
      [LineType type = LineType.step, Direction dir = Direction.horizontal]) {
    if (points.length <= 1 || type.ratio < 0 || type.ratio > 1) {
      return [...points];
    }
    List<Offset> list = [];
    for (int i = 0; i < points.length - 1; i++) {
      Offset cur = points[i];
      Offset next = points[i + 1];
      if (i == 0) {
        list.addAll(type.convert(cur, next, dir));
      } else {
        list.addAll(type.convert(cur, next, dir).sublist(1));
      }
    }
    return list;
  }

  @override
  void fill(Attrs attr) {}


}
