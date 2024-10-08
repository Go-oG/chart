import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///半径轴
class RadiusAxisView extends LineAxisView<RadiusAxis, RadiusAxisAttrs, PolarCoord> {
  RadiusAxisView(super.context, super.axis, super.coord, {super.axisIndex});

  @override
  Future<void>  onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) async{
    var size = min(widthSpec.size, heightSpec.size);
    setMeasuredDimension(size, size);
  }

  @override
  List<Drawable>? onUpdateSplitArea(RadiusAxisAttrs attrs, BaseScale<dynamic> scale) {
    var splitArea = axis.splitArea;
    if (!splitArea.show) {
      return null;
    }
    return null;
  }

  @override
  List<Drawable>? onUpdateSplitLine(RadiusAxisAttrs attrs, BaseScale<dynamic> scale) {
    return null;
  }

  @override
  void onDrawAxisPointer(Canvas2 canvas, Paint paint, Offset touchOffset) {
    var axisPointer = axis.axisPointer;
    if (axisPointer == null || !axisPointer.show) {
      return;
    }
    var ir = attrs.start.distance2(attrs.center);
    var or = attrs.end.distance2(attrs.center);
    var dis = touchOffset.distance2(attrs.center);
    if (dis <= ir || dis >= or) {
      return;
    }

    bool snap = axisPointer.snap ?? (axis.isCategoryAxis || axis.isTimeAxis);
    Arc arc;
    if (snap) {
      var interval = axisScale.getBandSize(0);
      var diff = dis - ir;
      int c = diff ~/ interval;
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
        dis = c * interval * 1;
      }
      arc = Arc(
        innerRadius: 0,
        outRadius: dis,
        startAngle: axis.offsetAngle,
        sweepAngle: 360,
        center: attrs.center,
      );
    } else {
      arc = Arc(
        innerRadius: 0,
        outRadius: touchOffset.distance2(attrs.center),
        startAngle: axis.offsetAngle,
        sweepAngle: 360,
        center: attrs.center,
      );
    }
    axisPointer.lineStyle.drawPath(canvas, paint, arc.path);
  }

  num dataToRadius(dynamic data) {
    checkDataType(data);
    return axisScale.convert(data);
  }

  @override
  RadiusAxisAttrs onBuildDefaultAttrs() => RadiusAxisAttrs(Offset.zero, Rect.zero, Offset.zero, Offset.zero);

  @override
  BaseScale get axisScale => throw UnimplementedError();
}
