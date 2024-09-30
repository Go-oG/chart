import 'dart:math';

import 'package:e_chart/e_chart.dart';

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
}
