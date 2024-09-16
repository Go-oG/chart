import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///雷达图坐标系
///经过该坐标系布局后所有的节点都有 x,y 属性
class RadarCoordImpl extends RadarCoord {
  final Map<RadarAxis, RadarAxisView> axisMap = {};
  List<RadarSplit> splitList = [];
  Offset _center = Offset.zero;
  double radius = 0;

  RadarCoordImpl(super.context, super.props) {
    for (int i = 0; i < option.indicator.length; i++) {
      var axis = option.indicator[i];
      var view = RadarAxisView(context, axis, this, axisIndex: i);
      view.axisIndex = i;

      addView(view);
      axisMap[axis] = view;
    }
  }

  @override
  void onDispose() {
    axisMap.forEach((key, value) {
      value.dispose();
    });
    axisMap.clear();
    splitList.clear();
    super.onDispose();
  }

  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    var size = min(widthSpec.size, heightSpec.size);
    double cv = option.radius.last.convert(size);
    cv = min(cv, size) * 2;
    var spec = MeasureSpec.exactly(cv);
    for (var child in children) {
      child.measure(spec, spec);
    }
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    _center = Offset(option.center[0].convert(width), option.center[1].convert(height));

    double itemAngle = 360 / option.indicator.length;
    if (!option.clockwise) {
      itemAngle *= -1;
    }
    radius = width / 2;

    ///布局Axis
    num oa = option.offsetAngle;
    each(option.indicator, (p0, i) {
      var axis = axisMap[p0]!;
      double angle = oa + i * itemAngle;
      Offset o = circlePoint(radius, angle, center);
      var attrs = axis.attrs.copy() as LineAxisAttrs;
      attrs.scaleRatio = scaleX;
      attrs.scrollX = 0;
      attrs.start = center;
      attrs.end = o;
      axis.attrs = attrs;
      axis.layout(center.dx - axis.width / 2, center.dy - axis.height / 2, center.dx + axis.width / 2,
          center.dy + axis.height / 2);
    });
    double rInterval = radius / option.splitNumber;
    int axisCount = option.indicator.length;

    ///Shape Path
    List<RadarSplit> splitList = [];

    Path? lastPath;
    for (int i = 0; i < option.splitNumber; i++) {
      double r = rInterval * (i + 1);
      Path path;
      if (option.shape == RadarShape.circle) {
        path = Circle(radius: r, center: center).path;
      } else {
        path = PositiveShape(r: r, count: axisCount, center: center, angleOffset: option.offsetAngle).path;
      }

      if (lastPath == null) {
        lastPath = path;
        splitList.add(RadarSplit([], i, path));
      } else {
        Path p2 = Path.combine(PathOperation.difference, path, lastPath);
        splitList.add(RadarSplit([], i, p2));
        lastPath = path;
      }
    }
    this.splitList = splitList;

    ///布局孩子
    for (var child in children) {
      child.layout(0, 0, width, height);
    }
  }

  @override
  void onDraw(Canvas2 canvas) {
    _drawShape(canvas);
    _drawAxis(canvas);
  }

  void _drawShape(Canvas2 canvas) {
    var axisTheme = context.option.theme.valueAxisTheme;
    each(splitList, (sp, i) {
      var style = option.splitArea.getStyle(i, splitList.length, axisTheme);
      style.drawPath(canvas, mPaint, sp.splitPath);

      var lineStyle = option.splitLine.getStyle(sp.data, i, splitList.length, axisTheme);
      lineStyle.drawPath(canvas, mPaint, sp.splitPath);
    });
  }

  void _drawAxis(Canvas2 canvas) {
    ///绘制主轴
    axisMap.forEach((key, value) {
      value.draw(canvas);
    });
  }

  @override
  Offset get center => _center;

  @override
  double getRadius() => radius;

  @override
  double convert(AxisDim dim, double ratio) {
    var axisNode = axisMap[option.indicator[dim.index]]!;
    if (dim.isCol) {
      return axisNode.attrs.end.angle(axisNode.attrs.start);
    }
    return axisNode.axisScale.convertRatio(ratio);
  }

  @override
  double convert2(AxisDim dim, dynamic value) {
    var axisNode = axisMap[option.indicator[dim.index]]!;
    if (dim.isCol) {
      return axisNode.attrs.end.angle(axisNode.attrs.start);
    }
    return axisNode.axisScale.convert(value);
  }
}

abstract class RadarCoord extends CircleCoordLayout<Radar> {
  RadarCoord(super.context, super.props);

  Offset get center;

  double getRadius();

  @override
  int get dimCount => 2;

  @override
  int getDimAxisCount(Dim dim) => dim.isY ? 1 : option.indicator.length;

  double convert2(AxisDim dim, dynamic value);
}

class RadarPosition {
  final Offset center;
  final num radius;
  final num angle;

  RadarPosition(this.center, this.radius, this.angle);

  Offset get point {
    return circlePoint(radius, angle, center);
  }
}

class RadarSplit {
  final List<dynamic> data;
  final int index;
  final Path splitPath;

  RadarSplit(this.data, this.index, this.splitPath);
}
