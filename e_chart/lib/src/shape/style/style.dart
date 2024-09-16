import 'dart:ui';
import 'package:e_chart/e_chart.dart';

abstract class CStyle {
  final int priority;

  const CStyle({this.priority = 1});

  CStyle lerpTo(covariant CStyle? end, double t);

  void draw(Canvas2 canvas, Paint paint) {}

  void drawCircle(Canvas2 canvas, Paint paint, Offset center, num radius);

  void drawLine(Canvas2 canvas, Paint paint, Offset start, Offset end, [Rect? bounds]);

  void drawPolygon(Canvas2 canvas, Paint paint, List<Offset> points, [bool closed = true, Rect? bound]);

  void drawRect(Canvas2 canvas, Paint paint, Rect rect, [Corner? corner]);

  void drawRRect(Canvas2 canvas, Paint paint, RRect rect);

  void drawArc(Canvas2 canvas, Paint paint, Arc arc, [bool useCircleRect = false]);

  void drawArc2(Canvas2 canvas, Paint paint, num radius, num startAngle, num sweepAngle, [Offset center = Offset.zero]);

  void drawPath(Canvas2 canvas, Paint paint, Path path, [Rect? bound]);

  void drawDashPath(Canvas2 canvas, Paint paint, Path path, [Rect? bound]);

  void dispose() {}
}
