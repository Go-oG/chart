import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///用于实现极坐标系
///支持 柱状图 折线图 散点图
class PolarCoordImpl extends PolarCoord {
  AngleAxisView? _angleAxis;
  AngleAxisView get angleAxis => _angleAxis!;
  RadiusAxisView? _radiusAxis;
  RadiusAxisView get radiusAxis => _radiusAxis!;
  Offset _center = Offset.zero;

  PolarCoordImpl(super.context, super.props) {
    _angleAxis = AngleAxisView(context, option.angleAxis, this, axisIndex: 0);
    _radiusAxis = RadiusAxisView(context, option.radiusAxis, this, axisIndex: 0);
    addView(_angleAxis!);
    addView(_radiusAxis!);
  }

  @override
  void onDispose() {
    super.onDispose();
    _angleAxis = null;
    _radiusAxis = null;
  }

  @override
  void onHoverStart(Offset local, Offset global) {}

  @override
  void onHoverMove(Offset local, Offset global, Offset lastLocal, Offset lastGlobal) {}

  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    double size = m.min(widthSpec.size, heightSpec.size);
    size = option.radius.last.convert(size) * 2;
    var spec = MeasureSpec.exactly(size);
    for (var child in children) {
      child.measure(spec, spec);
    }
    setMeasuredDimension(size, size);
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    _center = Offset(option.center[0].convert(width), option.center[1].convert(height));
    contentBox = Rect.fromCircle(center: center, radius: width / 2);
    double size = measureWidth;
    double ir = option.radius.length > 1 ? option.radius.first.convert(size) : 0;
    double or = width / 2;

    angleAxis.attrs = AngleAxisAttrs(
      center,
      option.angleAxis.offsetAngle.toDouble(),
      [ir, or],
      scaleRatio: scaleX,
      scrollY: translationY,
      clockwise: option.angleAxis.clockwise,
    );
    angleAxis.layout(0, 0, width, height);

    double angle = option.radiusAxis.offsetAngle;
    Offset so = ir <= 0 ? center : circlePoint(ir, angle, center);
    Offset eo = circlePoint(or, angle, center);
    radiusAxis.attrs = RadiusAxisAttrs(center, contentBox, so, eo);

    for (var c in children) {
      if (c == angleAxis || c == radiusAxis) {
        continue;
      }
      c.layout(0, 0, c.measureWidth, c.measureHeight);
    }
  }

  @override
  void onDraw(Canvas2 canvas) {
    angleAxis.draw(canvas);
    radiusAxis.draw(canvas);
  }

  @override
  BaseScale<dynamic> getScale(bool angleAxis) {
    if (angleAxis) {
      return this.angleAxis.axisScale;
    }
    return radiusAxis.axisScale;
  }

  @override
  List<double> getRadius() {
    return angleAxis.attrs.radius;
  }

  @override
  double convert(AxisDim dim, double ratio) {
    if (dim.isCol) {
      return angleAxis.axisScale.convertRatio(ratio);
    } else {
      return radiusAxis.axisScale.convertRatio(ratio);
    }
  }

  @override
  double convert2(AxisDim dim, dynamic value) {
    if (dim.isCol) {
      return angleAxis.axisScale.convert(value);
    } else {
      return radiusAxis.axisScale.convertRatio(value);
    }
  }

  @override
  Offset get center => _center;
}

abstract class PolarCoord extends CircleCoordLayout<Polar> {
  PolarCoord(super.context, super.props);

  @override
  int get dimCount => 2;

  @override
  int getDimAxisCount(Dim dim) => 1;

  Offset get center;

  List<double> getRadius();

  BaseScale getScale(bool angleAxis);

  double convert2(AxisDim dim, dynamic value);
}

class PolarPosition {
  final Offset center;

  ///当radius是一个范围时起长度为2 否则为1
  final List<num> radius;

  ///当angle是一个范围时起长度为2 否则为1
  final List<num> angle;

  const PolarPosition(this.center, this.radius, this.angle);

  @override
  String toString() {
    return "$runtimeType $center radius:$radius angle:$angle";
  }

  Offset get position {
    num a;
    if (angle.length >= 2) {
      a = (angle.first + angle.last) / 2;
    } else {
      a = angle.first;
    }
    num r;
    if (radius.length >= 2) {
      r = (radius.first + radius.last) / 2;
    } else {
      r = radius.last;
    }

    return circlePoint(r, a, center);
  }
}
