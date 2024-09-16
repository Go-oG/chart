import 'dart:math';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class LineAxisView<T extends BaseAxis, P extends LineAxisAttrs, C extends CoordView>
    extends AxisView<T, P, C> {
  LineAxisView(super.context, super.axis, super.coord, {super.axisIndex});

  ///返回坐标轴的映射长度
  double get axisLength => attrs.distance;

  ///返回坐标轴的夹角
  ///夹角为轴线与轴线起点水平方向的夹角
  double get axisAngle => attrs.end.angle(attrs.start);

  @override
  List<Drawable>? onUpdateAxisLine(P attrs, BaseScale<dynamic> scale) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      return null;
    }

    var lineStyle = axisLine.getStyle(axisTheme);

    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = scale.bandSize.toDouble();
    List<AxisLineDrawable> resultList = [];
    var angle = axisAngle;
    final int maxCount = tickCount - 1;
    for (int i = 0; i < maxCount; i++) {
      var dis = interval * i;
      var nextDis = dis + interval;
      var offset = attrs.start.translate(dis, 0);
      var start = offset.rotate(angle, center: attrs.start);
      var startData = scale.invert(dis);
      var end = attrs.start.translate(nextDis, 0).rotate(angle, center: attrs.start);
      var endData = scale.invert(nextDis);
      resultList.add(AxisLineDrawable.of([startData, endData], i, maxCount, start, end, lineStyle));
    }
    return resultList;
  }

  @override
  List<Drawable>? onUpdateTick(P attrs, BaseScale<dynamic> scale) {
    var axisTick = axis.axisTick;
    var tick = axisTick.tick;
    if (!axisTick.show || (tick == null || !tick.show)) {
      return null;
    }

    var minorTick = axisTick.minorTick;

    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }

    final double interval = scale.bandSize;
    final int insideDir = axisTick.inside ? -1 : 1;
    final double tickOffset = axisTick.getTickSize() * insideDir;
    final double minorOffset = axisTick.getMinorSize() * insideDir;
    final minorCount = minorTick?.splitNumber ?? 0;
    final double minorInterval = minorCount <= 0 ? 0 : (interval / (minorCount + 1));

    List<TickDrawable> resultList = [];
    final center = attrs.start;
    final angle = axisAngle;

    for (int i = 0; i < tickCount; i++) {
      var dis = interval * i;
      final offset = center.translate(dis, 0);
      var start = offset.rotate(angle, center: center);
      var end = offset.translate(0, tickOffset).rotate(angle, center: center);
      var data = scale.invert(dis);
      var tickNode = TickDrawable.of(data, i, tickCount, start, end, tick.lineStyle, []);
      resultList.add(tickNode);
      if (minorCount <= 0 || minorTick == null || !minorTick.show) {
        continue;
      }
      for (int j = 1; j < minorCount; j++) {
        var dis2 = minorInterval * j;
        var ms = offset.translate(dis2, 0);
        var me = ms.translate(0, minorOffset);
        var data = scale.invert(dis2 + dis);
        ms = ms.rotate(angle, center: center);
        me = me.rotate(angle, center: center);
        tickNode.minorList?.add(TickDrawable.of(data, i, tickCount, ms, me, minorTick.lineStyle));
      }
    }
    return resultList;
  }

  @override
  List<Drawable>? onUpdateLabel(P attrs, BaseScale<dynamic> scale) {
    var axisLabel = axis.axisLabel;
    if (!axisLabel.show) {
      return null;
    }
    final labels = obtainLabel();
    final int labelCount = labels.length;
    if (labelCount <= 0) {
      return null;
    }

    var axisTick = axis.axisTick;
    final tickSize = axisTick.getMaxTickSize();

    ///计算 Label偏移量
    double labelOffset = axisLabel.padding + axisLabel.margin + 0;
    if (axisLabel.inside == axisTick.inside) {
      labelOffset += tickSize;
    }
    labelOffset *= axisLabel.inside ? -1 : 1;

    List<AxisLabelDrawable> resultList = [];
    final center = attrs.start;
    final angle = axisAngle;

    double labelInterval = axisLength / (labelCount - 1);
    double startOffset = 0;
    if (axis.isCategoryAxis && axis.categoryCenter) {
      labelInterval = axisLength / labelCount;
      startOffset = labelInterval * 0.5;
    }

    each(labels, (label, i) {
      final double dis = startOffset + i * labelInterval;
      final offset = center.translate(dis, 0);
      var textOffset = offset.translate(0, labelOffset).rotate(angle, center: center);

      var ls = axisLabel.getStyle(i, labelCount, axisTheme);
      var config = Text2(
        text: label,
        style: ls,
        alignPoint: textOffset,
        pointAlign: toAlignment(angle + 90, axisLabel.inside),
        rotate: axisLabel.rotate,
      );
      var result = AxisLabelDrawable.of(i, labelCount, config, []);
      resultList.add(result);
    });

    return resultList;
  }

  @override
  List<Drawable>? onUpdateAxisTitle(P attrs, BaseScale<dynamic> scale) {
    Offset center;
    Offset p;
    var align = axis.axisName?.align ?? Align2.end;
    if (align == Align2.end) {
      center = attrs.start;
      p = attrs.end;
    } else if (align == Align2.start) {
      center = attrs.end;
      p = attrs.start;
    } else {
      center = attrs.start;
      p = Offset((attrs.start.dx + attrs.end.dx) / 2, (attrs.start.dy + attrs.end.dy) / 2);
    }
    num a = p.angle(center);
    double r = center.distance2(p);
    r += axis.axisName?.nameGap ?? 0;
    var label = axis.axisName?.name ?? DynamicText.empty;
    var s = axis.axisName?.labelStyle ?? const LabelStyle();
    return [Text2(text: label, style: s, alignPoint: circlePoint(r, a, center), pointAlign: toAlignment(a))];
  }

  Offset dataToPosition(dynamic data) {
    checkDataType(data);
    double diffY = attrs.end.dy - attrs.start.dy;
    double diffX = attrs.end.dx - attrs.start.dx;
    double at = atan2(diffY, diffX);
    double nl = axisScale.convert(data);

    double x = attrs.start.dx + nl * cos(at);
    double y = attrs.start.dy + nl * sin(at);
    return Offset(x, y);
  }

  double getLength() {
    return attrs.distance;
  }
}
