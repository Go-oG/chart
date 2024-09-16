import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class RadarAxisView extends LineAxisView<RadarAxis, LineAxisAttrs, RadarCoord> {
  RadarAxisView(super.context, super.axis, super.coord, {super.axisIndex});

  @override
  List<Drawable>? onUpdateSplitArea(LineAxisAttrs attrs, BaseScale<dynamic> scale) {
    var splitArea = axis.splitArea;
    if (!splitArea.show) {
      return null;
    }
    List<Drawable> list = [];
    int tickCount = scale.tickCount;
    double interval = scale.bandSize;
    var angle = axisAngle;
    for (int i = 0; i < tickCount - 1; i++) {
      var style = splitArea.getStyle(i, tickCount - 1, axisTheme);
      var arc = Arc(
          center: attrs.start,
          innerRadius: interval * i,
          outRadius: interval * (i + 1),
          sweepAngle: 360,
          startAngle: angle);

      list.add(SplitAreaDrawable.of([], arc.path, style));
    }
    return list;
  }

  @override
  List<Drawable>? onUpdateSplitLine(LineAxisAttrs attrs, BaseScale<dynamic> scale) {
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      return null;
    }
    List<Drawable> list = [];
    int tickCount = scale.tickCount;
    double interval = scale.bandSize;
    var angle = axisAngle;
    for (int i = 1; i < tickCount - 1; i++) {
      var style = splitLine.getStyle([], i, tickCount - 1, axisTheme);
      list.add(AxisCurveDrawable.of([], i, tickCount - 1, attrs.start, interval * i, angle, 360, style));
    }
    return list;
  }

  @override
  LineAxisAttrs onBuildDefaultAttrs() => LineAxisAttrs(Rect.zero, Offset.zero, Offset.zero);

  @override
  BaseScale get axisScale {
    var parent = this.parent as CoordView;
    return context.dataManager.getAxisScale(parent.id, AxisDim.of(Dim.x, axisIndex));
  }
}
