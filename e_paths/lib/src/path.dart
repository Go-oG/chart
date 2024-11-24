import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:e_paths/src/raw_operation.dart';
import 'package:flutter/rendering.dart';

import 'cubic.dart';

typedef PathSegment = List<Cubic>;

final class Path {
  late ui.Path _path;

  ui.Path get rawPath => _path;

  final List<RawOperation> _list = [];

  List<RawOperation> get operationList => _list;

  Path() {
    _path = ui.Path();
  }

  Path._(ui.Path p) {
    _path = p;
  }

  Path copy() {
    var path = Path();
    path._path = ui.Path.from(_path);
    path._list.addAll(_list);
    return path;
  }

  void draw(ui.Canvas canvas, ui.Paint paint) {
    canvas.drawPath(_path, paint);
  }

  PathFillType get fillType => _path.fillType;

  set fillType(PathFillType value) {
    _list.add(PathFillTypeOperation(_list.length, value));
    _path.fillType = value;
  }

  void moveTo(double x, double y) {
    _list.add(MoveOperation(_list.length, false, x, y));
    _path.moveTo(x, y);
  }

  void moveTo2(Offset offset) {
    moveTo(offset.dx, offset.dy);
  }

  void relativeMoveTo(double dx, double dy) {
    _list.add(MoveOperation(_list.length, true, dx, dy));
    _path.relativeMoveTo(dx, dy);
  }

  void lineTo(double x, double y) {
    _list.add(LineOperation(_list.length, false, x, y));
    _path.lineTo(x, y);
  }

  void lineTo2(Offset offset) {
    lineTo(offset.dx, offset.dy);
  }

  void relativeLineTo(double dx, double dy) {
    _list.add(LineOperation(_list.length, true, dx, dy));
    _path.relativeLineTo(dx, dy);
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _list.add(QuadraticBezierOperation(_list.length, false, x1, y1, x2, y2));
    _path.quadraticBezierTo(x1, y1, x2, y2);
  }

  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    _list.add(QuadraticBezierOperation(_list.length, true, x1, y1, x2, y2));
    _path.relativeQuadraticBezierTo(x1, y1, x2, y2);
  }

  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    _list.add(CubicOperation(_list.length, false, x1, y1, x2, y2, x3, y3));
    _path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  void relativeCubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    _list.add(CubicOperation(_list.length, true, x1, y1, x2, y2, x3, y3));
    _path.relativeCubicTo(x1, y1, x2, y2, x3, y3);
  }

  void conicTo(double x1, double y1, double x2, double y2, double w) {
    _list.add(ConicOperation(_list.length, false, x1, y1, x2, y2, w));
    _path.conicTo(x1, y1, x2, y2, w);
  }

  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    _list.add(ConicOperation(_list.length, true, x1, y1, x2, y2, w));
    _path.relativeConicTo(x1, y1, x2, y2, w);
  }

  void arcTo(Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    _list.add(ArcToOperation(_list.length, rect, startAngle, sweepAngle, forceMoveTo));
    _path.arcTo(rect, startAngle, sweepAngle, forceMoveTo);
  }

  void arcToPoint(
    Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    _list.add(ArcToPointOperation(_list.length, false, arcEnd, radius, rotation, largeArc, clockwise));
    _path.arcToPoint(arcEnd, radius: radius, rotation: rotation, largeArc: largeArc, clockwise: clockwise);
  }

  void relativeArcToPoint(
    Offset arcEndDelta, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    _list.add(ArcToPointOperation(_list.length, true, arcEndDelta, radius, rotation, largeArc, clockwise));
    _path.relativeArcToPoint(
      arcEndDelta,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  void addRect(Rect rect) {
    _list.add(RectOperation(_list.length, rect));
    _path.addRect(rect);
  }

  void addOval(Rect oval) {
    _list.add(OvalOperation(_list.length, oval));
    _path.addOval(oval);
  }

  void addArc(Rect oval, double startAngle, double sweepAngle) {
    _list.add(ArcOperation(_list.length, oval, startAngle, sweepAngle));
    _path.addArc(oval, startAngle, sweepAngle);
  }

  void addPolygon(List<Offset> points, bool close) {
    _list.add(PolygonOperation(_list.length, points, close));
    _path.addPolygon(points, close);
  }

  void addRRect(RRect rrect) {
    _list.add(RRectOperation(_list.length, rrect));
    _path.addRRect(rrect);
  }

  void addPath(Path path, Offset offset, {Float64List? matrix4}) {
    _list.add(PathPathOperation(_list.length, path, offset, matrix4));
    _path.addPath(path.rawPath, offset, matrix4: matrix4);
  }

  void extendWithPath(ui.Path path, Offset offset, {Float64List? matrix4}) {
    _list.add(ExtendPathOperation(_list.length, path, offset, matrix4));
    _path.extendWithPath(path, offset, matrix4: matrix4);
  }

  void close() {
    _list.add(ClosePathOperation(
      _list.length,
    ));
    _path.close();
  }

  void reset() {
    _list.clear();
    _path.reset();
  }

  PathMetrics computeMetrics({bool forceClosed = false}) {
    return rawPath.computeMetrics(forceClosed: forceClosed);
  }

  bool contains(Offset point) => _path.contains(point);

  bool overlapRect(Rect rect) {
    if (contains(rect.topLeft)) {
      return true;
    }
    if (contains(rect.topRight)) {
      return true;
    }
    if (contains(rect.bottomLeft)) {
      return true;
    }
    if (contains(rect.bottomRight)) {
      return true;
    }
    var bound = getBounds();
    return bound.overlaps(rect);
  }

  Path shift(Offset offset) {
    List<RawOperation> list = List.from(_list);
    list.add(ShiftOperation(_list.length, offset));

    var path = _path.shift(offset);
    var result = Path._(path);
    result._list.addAll(list);
    return result;
  }

  Path transform(Float64List matrix4) {
    List<RawOperation> list = List.from(_list);
    list.add(TransformPathOperation(_list.length, matrix4));
    var path = _path.transform(matrix4);
    var result = Path._(path);
    result._list.addAll(list);
    return result;
  }

  Rect getBounds() => _path.getBounds();

  List<List<PathSegment>> pickSegment() {
    List<List<PathSegment>> result = [];
    List<PathSegment> next = [];
    for (var item in _list) {
      var rr = item.pickBorder(this);
      if (rr != null && rr.isNotEmpty) {
        next.add(rr);
      }
      if (item.effectPathLevel) {
        if (next.isNotEmpty) {
          result.add(next);
          next = [];
        }
      }
    }
    if (next.isNotEmpty) {
      result.add(next);
    }
    return result;
  }

  static ui.Path dash(ui.Path path, List<double> dash) {
    if (dash.isEmpty) {
      return path;
    }
    double dashLength = dash[0];
    double dashGapLength = dashLength >= 2 ? dash[1] : dash[0];
    DashHelper helper = DashHelper(
      path: ui.Path(),
      dashLength: dashLength,
      dashGapLength: dashGapLength,
    );
    final metricsIterator = path.computeMetrics().iterator;
    while (metricsIterator.moveNext()) {
      final metric = metricsIterator.current;
      helper.extractedPathLength = 0.0;
      while (helper.extractedPathLength < metric.length) {
        if (helper.addDashNext) {
          helper.addDash(metric, dashLength);
        } else {
          helper.addDashGap(metric, dashGapLength);
        }
      }
    }
    return helper.path;
  }

  /// 给定一个Path和路径百分比返回给定百分比路径
  static ui.Path percentPath(ui.Path path, double percent) {
    if (percent >= 1) {
      return path;
    }
    if (percent <= 0) {
      return path;
    }
    PathMetrics metrics = path.computeMetrics();
    ui.Path newPath = ui.Path();

    for (PathMetric metric in metrics) {
      ui.Path tmp = metric.extractPath(0, metric.length * percent);
      newPath.addPath(tmp, Offset.zero);
    }
    return newPath;
  }

  static Offset? percentOffset(ui.Path path, double percent) {
    PathMetrics metrics = path.computeMetrics();
    for (PathMetric metric in metrics) {
      if (metric.length <= 0) {
        continue;
      }
      var result = metric.getTangentForOffset(metric.length * percent);
      if (result == null) {
        continue;
      }
      return result.position;
    }
    return null;
  }

  static Offset? firstOffset(ui.Path path) {
    PathMetrics metrics = path.computeMetrics();
    for (PathMetric metric in metrics) {
      if (metric.length <= 0) {
        continue;
      }
      var result = metric.getTangentForOffset(1);
      if (result == null) {
        continue;
      }
      return result.position;
    }
    return null;
  }

  static Offset? lastOffset(ui.Path path) {
    PathMetrics metrics = path.computeMetrics();
    List<Offset> ol = [];
    for (PathMetric metric in metrics) {
      if (metric.length <= 0) {
        continue;
      }
      var result = metric.getTangentForOffset(metric.length);
      if (result == null) {
        continue;
      }
      ol.add(result.position);
    }
    if (ol.isEmpty) {
      return null;
    }
    return ol[ol.length - 1];
  }

  static double getLength(ui.Path path) {
    double l = 0;
    for (PathMetric metric in path.computeMetrics()) {
      l += metric.length;
    }
    return l;
  }

  ///将当前Path进行拆分
  List<ui.Path> split([double maxLength = 300]) {
    List<ui.Path> pathList = [];

    for (PathMetric metric in computeMetrics()) {
      final double length = metric.length;
      if (metric.length <= 0) {
        continue;
      }
      if (length <= maxLength) {
        pathList.add(metric.extractPath(0, length));
        continue;
      }
      double start = 0;
      while (start < length) {
        double end = start + maxLength;
        if (end > length) {
          end = length;
        }
        pathList.add(metric.extractPath(start, end));
        if (end >= length) {
          break;
        }
        start += maxLength;
      }
    }
    return pathList;
  }

  ///合并两个Path,并将其头相连，尾相连
  Path mergePath(Path p2) {
    Path path = this;
    PathMetric metric = p2.computeMetrics().single;
    double length = metric.length;
    while (length >= 0) {
      Tangent? t = metric.getTangentForOffset(length);
      if (t != null) {
        Offset offset = t.position;
        path.lineTo(offset.dx, offset.dy);
      }
      length -= 1;
    }
    path.close();
    return path;
  }

  void drawShadows(Path path, List<BoxShadow> shadows, void Function(Path path, ui.Paint paint) canvasCall) {
    for (final BoxShadow shadow in shadows) {
      final Paint shadowPainter = shadow.toPaint();
      if (shadow.spreadRadius == 0) {
        canvasCall.call(path.shift(shadow.offset), shadowPainter);
      } else {
        Rect zone = path.getBounds();
        double xScale = (zone.width + shadow.spreadRadius) / zone.width;
        double yScale = (zone.height + shadow.spreadRadius) / zone.height;
        Matrix4 m4 = Matrix4.identity();
        m4.translate(zone.width / 2, zone.height / 2);
        m4.scale(xScale, yScale);
        m4.translate(-zone.width / 2, -zone.height / 2);
        canvasCall.call(path.shift(shadow.offset).transform(m4.storage), shadowPainter);
      }
    }
  }
}

class DashHelper {
  double extractedPathLength;
  ui.Path path;

  final double _dashLength;
  double _remainingDashLength;
  double _remainingDashGapLength;
  bool _previousWasDash;

  DashHelper({
    required this.path,
    required double dashLength,
    required double dashGapLength,
  })  : assert(dashLength > 0.0, 'dashLength must be > 0.0'),
        assert(dashGapLength > 0.0, 'dashGapLength must be > 0.0'),
        _dashLength = dashLength,
        _remainingDashLength = dashLength,
        _remainingDashGapLength = dashGapLength,
        _previousWasDash = false,
        extractedPathLength = 0.0;

  bool get addDashNext {
    if (!_previousWasDash || _remainingDashLength != _dashLength) {
      return true;
    }
    return false;
  }

  void addDash(PathMetric metric, double dashLength) {
    final end = _calculateLength(metric, _remainingDashLength).toDouble();
    final availableEnd = _calculateLength(metric, dashLength);
    final pathSegment = metric.extractPath(extractedPathLength.toDouble(), end);
    path.addPath(pathSegment, Offset.zero);
    final delta = _remainingDashLength - (end - extractedPathLength);
    _remainingDashLength = _updateRemainingLength(
      delta: delta,
      end: end,
      availableEnd: availableEnd,
      initialLength: dashLength,
    );
    extractedPathLength = end;
    _previousWasDash = true;
  }

  void addDashGap(PathMetric metric, double dashGapLength) {
    final end = _calculateLength(metric, _remainingDashGapLength);
    final availableEnd = _calculateLength(metric, dashGapLength);
    Tangent tangent = metric.getTangentForOffset(end.toDouble())!;
    path.moveTo(tangent.position.dx, tangent.position.dy);
    final delta = end - extractedPathLength;
    _remainingDashGapLength = _updateRemainingLength(
      delta: delta,
      end: end,
      availableEnd: availableEnd,
      initialLength: dashGapLength,
    );
    extractedPathLength = end;
    _previousWasDash = false;
  }

  double _calculateLength(PathMetric metric, double addedLength) {
    return min(extractedPathLength + addedLength, metric.length);
  }

  double _updateRemainingLength({
    required double delta,
    required double end,
    required double availableEnd,
    required double initialLength,
  }) {
    return (delta > 0 && availableEnd == end) ? delta : initialLength;
  }
}

