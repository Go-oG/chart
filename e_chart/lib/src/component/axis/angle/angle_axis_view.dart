import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///角度轴(是一个完整的环,类似于Y轴)
class AngleAxisView extends AxisView<AngleAxis, AngleAxisAttrs, PolarCoord> {
  AngleAxisView(super.context, super.axis, super.coord, {super.axisIndex});

  @override
  Future<void> onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) async{
    var size = min(widthSpec.size, heightSpec.size);
    setMeasuredDimension(size, size);
  }

  @override
  List<Drawable>? onUpdateAxisLine(AngleAxisAttrs attrs, BaseScale scale) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      return null;
    }
    List<Drawable> list = [];
    int tickCount = scale.tickCount - 1;
    var s = axisLine.getStyle(axisTheme);
    for (int i = 0; i < tickCount; i++) {
      var render = AxisCurveDrawable.of([], i, tickCount, attrs.center, attrs.radius.last, attrs.angleOffset, 360, s);
      list.add(render);
    }
    return list;
  }

  @override
  List<Drawable>? onUpdateSplitLine(AngleAxisAttrs attrs, BaseScale scale) {
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      return null;
    }

    final maxAngle = axis.sweepAngle;
    int count = scale.tickCount - 1;
    final int dir = attrs.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / count;
    List<AxisCurveDrawable> list = [];
    double ir = attrs.radius.length > 1 ? attrs.radius.first : 0;
    double or = attrs.radius.last;

    for (int i = 0; i < count; i++) {
      num sa = attrs.angleOffset + angleInterval * i;
      var data = [];
      var style = splitLine.getStyle(data, i, count, axisTheme);
      var segment = AxisCurveDrawable.of(data, i, count, attrs.center, ir, or, sa, style);
      list.add(segment);
    }
    return list;
  }

  @override
  List<Drawable>? onUpdateSplitArea(AngleAxisAttrs attrs, BaseScale scale) {
    var splitArea = axis.splitArea;
    if (!splitArea.show) {
      return null;
    }
    final maxAngle = axis.sweepAngle;
    int count = scale.tickCount - 1;
    final int dir = attrs.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / count;
    List<SplitAreaDrawable> list = [];
    double ir = attrs.radius.length > 1 ? attrs.radius.first : 0;
    double or = attrs.radius.last;

    for (int i = 0; i < count; i++) {
      num sa = attrs.angleOffset + angleInterval * i;
      var arc = Arc(
        startAngle: sa.toDouble(),
        sweepAngle: angleInterval.toDouble(),
        outRadius: or,
        innerRadius: ir,
        center: attrs.center,
      );
      list.add(SplitAreaDrawable.of([], arc.path, splitArea.getStyle(i, count, axisTheme)));
    }
    return list;
  }

  @override
  List<Drawable>? onUpdateTick(AngleAxisAttrs attrs, BaseScale scale) {
    var axisTick = axis.axisTick;
    var tick = axisTick.tick;
    if (!axis.show || !axisTick.show || tick == null || !tick.show) {
      return null;
    }
    var minorTick = axisTick.minorTick;

    int tickCount = scale.tickCount - 1;
    if (scale.isCategory) {
      tickCount = scale.domain.length;
    }
    final maxAngle = axis.sweepAngle;
    final int dir = attrs.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / tickCount;
    List<TickDrawable> tickList = [];

    final int minorCount = minorTick?.splitNumber ?? 0;
    final minorInterval = angleInterval / minorCount;

    num r = attrs.radius.last;
    num minorR = attrs.radius.last;
    if (axis.axisTick.inside) {
      r -= tick.length;
      minorR -= axisTick.getMinorSize();
    } else {
      r += tick.length;
      minorR += axisTick.getMinorSize();
    }

    var tickStyle = tick.lineStyle;
    for (int i = 0; i < tickCount; i++) {
      double angle = attrs.angleOffset + angleInterval * i;
      Offset so = circlePoint(attrs.radius.last, angle, attrs.center);
      Offset eo = circlePoint(r, angle, attrs.center);
      List<TickDrawable> minorList = [];

      tickList.add(TickDrawable.of([scale.invert(angle)], i, tickCount, so, eo, tickStyle, minorList));
      if (axis.isCategoryAxis || axis.isTimeAxis || i >= tickCount - 1) {
        continue;
      }
      if (minorTick == null || minorCount <= 0 || !minorTick.show) {
        continue;
      }

      for (int j = 1; j < minorTick.splitNumber; j++) {
        var minorAngle = angle + minorInterval * j;
        Offset minorSo = circlePoint(attrs.radius.last, angle + minorInterval * j, attrs.center);
        Offset minorEo = circlePoint(minorR, angle + minorInterval * j, attrs.center);
        minorList.add(TickDrawable.of(scale.invert(minorAngle), i, tickCount, minorSo, minorEo, minorTick.lineStyle));
      }
    }

    return tickList;
  }

  @override
  List<Drawable>? onUpdateLabel(AngleAxisAttrs attrs, BaseScale scale) {
    var axisLabel = axis.axisLabel;
    if (!axisLabel.show) {
      return null;
    }
    final labels = obtainLabel();
    final int labelCount = labels.length;
    if (labelCount <= 1) {
      return null;
    }
    var axisTick = axis.axisTick;

    final int dir = attrs.clockwise ? 1 : -1;
    int count = scale.tickCount - 1;
    if (scale.isCategory) {
      count = labels.length;
    }

    final maxAngle = axis.sweepAngle;
    final num angleInterval = dir * maxAngle / count;
    num r = attrs.radius.last;
    if (axisTick.inside == axisLabel.inside) {
      r += axisLabel.margin + axisLabel.padding;
    } else {
      if (axisLabel.inside) {
        r -= axisLabel.margin + axisLabel.padding;
      } else {
        r += axisLabel.margin + axisLabel.padding;
      }
    }
    List<AxisLabelDrawable> resultList = [];

    for (int i = 0; i < labels.length; i++) {
      DynamicText text = labels[i];
      num d = i;
      if (axis.isCategoryAxis) {
        d += 0.5;
      }
      num angle = attrs.angleOffset + angleInterval * d;
      Offset offset = circlePoint(r, angle, attrs.center);
      var labelStyle = axisLabel.getStyle(i, labels.length, axisTheme);
      var config = Text2(
        text: text,
        style: labelStyle,
        alignPoint: offset,
        pointAlign: toAlignment(angle, axisLabel.inside),
        rotate: axisLabel.rotate,
      );
      var result = AxisLabelDrawable.of(i, labels.length, config, []);
      resultList.add(result);
    }
    return resultList;
  }

  @override
  List<Drawable>? onUpdateAxisTitle(AngleAxisAttrs attrs, BaseScale scale) {
    var label = titleNode.name?.name ?? DynamicText.empty;
    Offset start = attrs.center;
    Offset end = circlePoint(attrs.radius.last, attrs.angleOffset, attrs.center);
    var axisName = axis.axisName;
    var align = axisName?.align ?? Align2.end;
    var style = axisName?.labelStyle ?? const LabelStyle();
    if (align == Align2.center || label.isEmpty) {
      return [
        Text2(
            text: label,
            style: style,
            alignPoint: Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2),
            pointAlign: Alignment.center,
            rotate: axisName?.rotate ?? 0)
      ];
    }
    if (align == Align2.start) {
      return [
        Text2(
            text: label,
            style: style,
            alignPoint: start,
            pointAlign: Alignment.centerLeft,
            rotate: axisName?.rotate ?? 0)
      ];
    }
    return [
      Text2(
        text: label,
        style: style,
        alignPoint: end,
        pointAlign: toAlignment(end.angle(start)),
        rotate: axisName?.rotate ?? 0,
      )
    ];
  }

  final Text2 _axisPointerTD = Text2.of(DynamicText.empty, LabelStyle.empty, Offset.zero);

  @override
  void onDrawAxisPointer(Canvas2 canvas, Paint paint, Offset touchOffset) {
    var axisPointer = axis.axisPointer;
    if (axisPointer == null || !axisPointer.show) {
      return;
    }
    double dis = touchOffset.distance2(attrs.center);
    var ir = attrs.radius.length > 1 ? attrs.radius[0] : 0;
    var or = attrs.radius.last;
    if (dis <= ir || dis >= or) {
      return;
    }
    if (dis <= 0 || dis > attrs.radius.last) {
      return;
    }
    bool snap = axisPointer.snap ?? (axis.isCategoryAxis || axis.isTimeAxis);
    List<Offset> ol;
    if (snap) {
      double interval = axisScale.getBandSize(0);
      int c = dis ~/ interval;
      if (axis.isCategoryAxis) {
        c -= 1;
      }
      if (!axis.isCategoryAxis) {
        int next = c + 1;
        num diff1 = (c * interval - dis).abs();
        num diff2 = (next * interval - dis).abs();
        if (diff1 > diff2) {
          c = next;
        }
      }
      if (axis.isCategoryAxis && axis.categoryCenter) {
        dis = (c + 0.5) * interval;
      } else {
        dis = c * interval;
      }
      final angle = touchOffset.angle(attrs.center);
      ol = [attrs.center, circlePoint(dis, angle, attrs.center)];
    } else {
      ol = [attrs.center, touchOffset];
    }
    axisPointer.lineStyle.drawPolygon(canvas, paint, ol);

    ///绘制 数据
    dis = ol.last.distance2(ol.first);
    var dt = axis.formatData(axisScale.invert(dis));
    num angle = touchOffset.angle(attrs.center);
    var o = circlePoint(attrs.radius.last, angle, attrs.center);

    if (_axisPointerTD.text != dt ||
        _axisPointerTD.alignPoint != o ||
        _axisPointerTD.pointAlign != toAlignment(angle, axis.axisLabel.inside)) {
      _axisPointerTD.alignPoint = o;
      _axisPointerTD.text = dt;
      _axisPointerTD.style = axisPointer.labelStyle;
      _axisPointerTD.pointAlign = toAlignment(angle, axis.axisLabel.inside);
      _axisPointerTD.markDirty();
    }
    _axisPointerTD.draw(canvas, paint);
  }

  @override
  void dispose() {
    super.dispose();
    _axisPointerTD.dispose();
  }

  @override
  AngleAxisAttrs onBuildDefaultAttrs() => AngleAxisAttrs(Offset.zero, 0, [0]);

  @override
  BaseScale get axisScale {
    var parent = this.parent as CoordView;
    return context.dataManager.getAxisScale(parent.option.id, AxisDim.of(Dim.x, axisIndex));
  }
}
