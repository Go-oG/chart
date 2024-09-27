import 'dart:math';
import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///边线样式
class LineStyle extends CStyle {
  static const LineStyle empty = LineStyle(width: 0);
  static const LineStyle normal = LineStyle(width: 1, color: Colors.black87);
  final Color? color;
  final num width;
  final StrokeCap cap;
  final StrokeJoin join;
  final List<num> dash;
  final List<BoxShadow> shadow;
  final CShader? shader;
  final num smooth;

  ///因为Flutter绘制直线时是平分的，
  ///因此为了优化视觉效果，提供了一个对齐方式
  final Align2 align;

  const LineStyle({
    this.color = Colors.black,
    this.width = 1,
    this.cap = StrokeCap.butt,
    this.join = StrokeJoin.miter,
    this.dash = const [],
    this.shadow = const [],
    this.shader,
    this.smooth = 0,
    this.align = Align2.center,
  });

  @override
  void drawLine(Canvas2 canvas, Paint paint, Offset start, Offset end, [Rect? bounds]) {
    if (notDraw) {
      return;
    }

    if (shader == null && shadow.isEmpty && dash.isEmpty && smooth <= 0) {
      fillPaint(paint, null);
      canvas.drawLine(start, end, paint);
      return;
    }

    Path path = Line([start, end], smooth: smooth, dashList: dash).path;
    fillPaint(paint, bounds ?? path.getBounds());
    canvas.drawPath(path, paint);
  }

  ///绘制多边形(或者线段) 将忽略smooth参数
  ///下方这样写是为了改善Flutter上Path过长时
  ///绘制效率低下的问题
  @override
  void drawPolygon(Canvas2 canvas, Paint paint, List<Offset> points, [bool closed = false, Rect? bound]) {
    if (notDraw || points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, paint);
      return;
    }
    if (shader == null && shadow.isEmpty && dash.isEmpty) {
      fillPaint(paint, null);
      canvas.drawPoints(closed ? PointMode.polygon : PointMode.lines, points, paint);
      return;
    }
    if (shader != null || shadow.isNotEmpty) {
      Path path = Line(points, smooth: 0).path;
      fillPaint(paint, path.getBounds());
    } else {
      fillPaint(paint, null);
    }
    List<List<Offset>> olList = [];
    List<Offset> tmpList = [];
    for (int i = 0; i < points.length; i++) {
      if (tmpList.isEmpty && i != 0) {
        tmpList.add(points[i - 1]);
      }
      tmpList.add(points[i]);
      if (tmpList.length >= 30) {
        olList.add(tmpList);
        tmpList = [];
      }
    }
    if (tmpList.isNotEmpty) {
      olList.add(tmpList);
    }
    if (closed) {
      olList.last.add(points.first);
    }
    for (var ol in olList) {
      if (ol.length == 1) {
        canvas.drawPoints(PointMode.points, ol, paint);
        continue;
      }
      if (smooth <= 0 && dash.isEmpty) {
        canvas.drawPoints(PointMode.polygon, ol, paint);
        continue;
      }
      Line line = Line(ol, smooth: smooth, dashList: dash);
      canvas.drawPath(line.path, paint);
    }
  }

  @override
  void drawArc2(Canvas2 canvas, Paint paint, num radius, num startAngle, num sweepAngle,
      [Offset center = Offset.zero]) {
    if (notDraw) {
      return;
    }
    //优化绘制半径、消除
    double r = radius.toDouble();
    if (align == Align2.start) {
      r -= width / 2;
    } else if (align == Align2.end) {
      r += width / 2;
    }

    Rect rect = Rect.fromCircle(radius: r, center: center);
    if (shader == null && shadow.isEmpty && dash.isEmpty) {
      fillPaint(paint);
      canvas.drawArc(rect, startAngle * angleUnit, sweepAngle * angleUnit, false, paint);
      return;
    }
    Path path = Path();
    path.addArc(rect, startAngle * angleUnit, sweepAngle * angleUnit);
    if (shadow.isNotEmpty) {
      path.drawShadows(canvas, path, shadow);
    }
    fillPaint(paint, rect);
    if (dash.isNotEmpty) {
      path = path.dashPath(dash);
    }
    canvas.drawPath(path, paint);
  }

  @override
  void drawCircle(Canvas2 canvas, Paint paint, Offset center, num radius) {
    if (notDraw) {
      return;
    }
    double r = radius.toDouble();
    if (align == Align2.start) {
      r -= width / 2;
    } else if (align == Align2.end) {
      r += width / 2;
    }
    if (shader == null && shadow.isEmpty && dash.isEmpty) {
      fillPaint(paint);
      canvas.drawCircle(center, r, paint);
      return;
    }

    Rect rect = Rect.fromCircle(radius: r, center: center);
    if (shadow.isNotEmpty || dash.isNotEmpty) {
      Path path = Path();
      path.addOval(rect);
      path.drawShadows(canvas, path, shadow);
      fillPaint(paint, rect);
      canvas.drawPath(path, paint);
    } else {
      fillPaint(paint, rect);
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  void drawRect(Canvas2 canvas, Paint paint, Rect rect, [Corner? corner]) {
    if (notDraw) {
      return;
    }
    if (shader == null && shadow.isEmpty && dash.isEmpty) {
      fillPaint(paint);
      if (corner == null || corner.isEmpty) {
        canvas.drawRect(rect, paint);
      } else {
        canvas.drawRRect(rect.toRRect(corner), paint);
      }
      return;
    }

    RRect? rRect;
    if (corner != null) {
      rRect = rect.toRRect(corner);
    }
    Rect? shaderRect;
    if (shader != null) {
      shaderRect = rect;
    }
    fillPaint(paint, shaderRect);

    if (shadow.isNotEmpty || dash.isNotEmpty) {
      Path path = Path();
      if (rRect != null) {
        path.addRRect(rRect);
      } else {
        path.addRect(rect);
      }
      if (shadow.isNotEmpty) {
        path.drawShadows(canvas, path, shadow);
      }
      if (dash.isNotEmpty) {
        path = path.dashPath(dash);
      }
      canvas.drawPath(path, paint);
      return;
    }

    if (rRect != null) {
      canvas.drawRRect(rRect, paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  void drawArc(Canvas2 canvas, Paint paint, Arc arc, [bool useCircleRect = false]) {
    drawPath(canvas, paint, arc.path, arc.bound);
  }

  @override
  void drawRRect(Canvas2 canvas, Paint paint, RRect rect) {
    fillPaint(paint, rect.outerRect);
    canvas.drawRRect(rect, paint);
  }

  @override
  void drawPath(Canvas2 canvas, Paint paint, Path path, [Rect? bound]) {
    if (notDraw) {
      return;
    }
    if (shadow.isNotEmpty) {
      path.drawShadows(canvas, path, shadow);
    }
    fillPaint(paint, shader == null ? null : (bound ?? path.getBounds()));
    canvas.drawPath(path, paint);
  }

  @override
  void drawDashPath(Canvas2 canvas, Paint paint, Path path, [Rect? bound]) {
    if (notDraw) {
      return;
    }
    if (dash.isNotEmpty) {
      path = path.dashPath(dash);
    }
    if (shadow.isNotEmpty) {
      path.drawShadows(canvas, path, shadow);
    }
    fillPaint(paint, shader == null ? null : (bound ?? path.getBounds()));
    canvas.drawPath(path, paint);
  }

  @override
  CStyle lerpTo(covariant LineStyle? end, double t) {
    return lerp(this, end, t);
  }

  static LineStyle lerp(LineStyle? start, LineStyle? end, double t) {
    if (start == null && end == null) {
      return LineStyle.empty;
    }
    var c = Color.lerp(start?.color, end?.color, t);
    var ss = start?.shader;
    var es = end?.shader;
    var shader = CShader.lerpShader(ss, es, t);
    var shadow = BoxShadow.lerpList(start?.shadow, end?.shadow, t) ?? [];
    var w = lerpDouble(start?.width, end?.width, t)!;
    if (w <= 0) {
      return LineStyle.empty;
    }

    return LineStyle(
      color: c,
      shader: shader,
      shadow: shadow,
      width: w,
      dash: CShader.lerpDoubles(start?.dash, end?.dash, t) ?? [],
      smooth: lerpDouble(start?.smooth, end?.smooth, t)!,
      cap: (end?.cap ?? start?.cap)!,
      join: (end?.join ?? start?.join)!,
      align: (end?.align ?? start?.align)!,
    );
  }

  @override
  int get hashCode {
    return Object.hashAll(
        [color, width, cap, join, Object.hashAll(dash), Object.hashAll(shadow), shader, smooth, align]);
  }

  @override
  bool operator ==(Object other) {
    if (other is! LineStyle) {
      return false;
    }
    if (other.color != color) {
      return false;
    }
    if (other.width != width) {
      return false;
    }
    if (other.cap != cap) {
      return false;
    }
    if (other.join != join) {
      return false;
    }
    if (!listEquals(other.dash, dash)) {
      return false;
    }
    if (!listEquals(other.shadow, shadow)) {
      return false;
    }
    if (other.shader != shader) {
      return false;
    }
    if (other.smooth != smooth) {
      return false;
    }
    return other.align == align;
  }

  Color? pickColor() {
    if (shader != null) {
      return shader!.pickColor();
    }
    return color;
  }

  ///判断当前样式转换为给定样式后是否会影响Path的路径
  bool changeEffect(LineStyle style) {
    if (cap != style.cap || join != style.join) {
      return true;
    }
    var s = max(0, smooth);
    var e = max(0, style.smooth);
    if (s != e) {
      return true;
    }
    return !equalList(dash, style.dash);
  }

  void fillPaint(Paint paint, [Rect? rect]) {
    paint.reset();
    if (color != null) {
      paint.color = color!;
    }
    paint.strokeCap = cap;
    paint.strokeJoin = join;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width.toDouble();
    if (shader != null && rect != null) {
      paint.shader = shader!.toShader(rect);
    }
  }

  LineStyle convert(Set<NodeState>? states) {
    if (states == null || states.isEmpty) {
      return this;
    }
    var c = this.color;
    if (c == null) {
      return this;
    }

    final Color color = ColorResolver(c).resolve(states)!;

    final CShader? shader = this.shader?.convert(states);

    final List<BoxShadow> shadow = [];
    for (var bs in this.shadow) {
      shadow.add(BoxShadow(
        color: ColorResolver(bs.color).resolve(states)!,
        offset: bs.offset,
        blurRadius: bs.blurRadius,
        spreadRadius: bs.spreadRadius,
        blurStyle: bs.blurStyle,
      ));
    }

    return LineStyle(
      color: color,
      width: width,
      cap: cap,
      join: join,
      dash: dash,
      smooth: smooth,
      shader: shader,
      shadow: shadow,
    );
  }

  Path buildPath(List<Offset> points, {LineType? lineType}) {
    if (points.length < 2) {
      throw ChartError('points length must >2');
    }
    bool hasStep = false;
    if (lineType != null && lineType != LineType.line) {
      hasStep = true;
      points = Line.step2(points, lineType);
    }
    return Line(points, smooth: hasStep ? 0 : smooth, dashList: dash).path;
  }

  bool get notDraw => width <= 0;

  bool get canDraw => width > 0;
}
