import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class YAxisImpl extends XAxisImpl {
  YAxisImpl(super.direction, super.coord, super.context, super.axis, {super.axisIndex});

  @override
  BaseScale get axisScale => context.dataManager.getAxisScale(coord.id, AxisDim.of(Dim.y, axisIndex));

  @override
  Future<void>  onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec)async {
    if (!axis.show) {
      setMeasuredDimension(0, heightSpec.size);
      return;
    }

    var lineWidth = axis.axisLine.getLength();
    var tickWidth = axis.axisTick.getMaxTickSize();

    double width = lineWidth + tickWidth;
    AxisLabel axisLabel = axis.axisLabel;
    if (axisLabel.show) {
      var labelWidth = axisLabel.margin + axisLabel.padding;
      var maxStr = attrs.maxStr;
      labelWidth += axisLabel.getStyle(0, 1, axisTheme).measure(maxStr).width;
      if (axisLabel.inside == axis.axisTick.inside) {
        width += labelWidth;
      } else {
        width = max(width, labelWidth + lineWidth);
      }
    }
    setMeasuredDimension(width, heightSpec.size);
  }

  @override
  List<int> computeRangeIndex(num distance, int tickCount, num interval) {
    Rect rect = coord.contentBox;
    int startIndex, endIndex;
    if (distance <= rect.height) {
      startIndex = 0;
      endIndex = tickCount;
    } else {
      double scroll = attrs.scrollX.abs();
      startIndex = scroll ~/ interval - 2;
      if (startIndex < 0) {
        startIndex = 0;
      }
      endIndex = (scroll + rect.height) ~/ interval + 2;
      if (endIndex > tickCount) {
        endIndex = tickCount;
      }
    }
    return [startIndex, endIndex];
  }
}
