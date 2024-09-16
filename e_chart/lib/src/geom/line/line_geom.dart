import 'package:e_chart/e_chart.dart';

///直线
class LineGeom extends Geom {
  double smooth = 0;
  List<double>? dashList;
  double disDiff = 2;
  LineType? lineType;

  LineGeom(
    super.dataSet,
    super.scope, {
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
