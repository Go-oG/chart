import 'dart:math';
import 'package:e_chart/e_chart.dart';

///横向轴
class XAxisImpl extends BaseGridAxisImpl {
  XAxisImpl(super.direction, super.coord, super.context, super.axis, {super.axisIndex});

  @override
  BaseScale get axisScale => context.dataManager.getAxisScale(coord.option.id, AxisDim.of(Dim.x, axisIndex));

  @override
  Future<void>  onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) async {
    if (!axis.show) {
      setMeasuredDimension(widthSpec.size, 0);
      return;
    }
    var lineHeight = axis.axisLine.getLength();
    var tickHeight = axis.axisTick.getMaxTickSize();

    double height = lineHeight + tickHeight;
    AxisLabel axisLabel = axis.axisLabel;
    if (axisLabel.show) {
      var labelHeight = axisLabel.margin + axisLabel.padding;
      labelHeight += axisLabel.getStyle(0, 1, axisTheme).measure(attrs.maxStr).height;
      if (axisLabel.inside == axis.axisTick.inside) {
        height += labelHeight;
      } else {
        height = max(height, labelHeight + lineHeight);
      }
    }
    setMeasuredDimension(widthSpec.size, height);
  }

}
