import 'package:e_chart/e_chart.dart';

///直线
class LineGeom extends PathGeom {
  LineType? lineType;

  LineGeom(
    super.dataSet,
    super.scope, {
    this.lineType,
    super.smooth,
    super.dashList,
    super.disDiff,
    super.animation,
    super.backgroundColor,
    super.clip,
    super.id,
    super.layoutParams,
    super.tooltip,
    super.cacheLayer,
  });

  @override
  GeomType get geomType => GeomType.line;

  @override
  ChartView? toView(Context context) {
    return LineView(context, this);
  }
}
