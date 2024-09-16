import '../../../e_chart.dart';

///直线
class PathGeom extends Geom {
  double smooth = 0;
  List<double>? dashList;

  double disDiff = 2;

  PathGeom(
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
  GeomType get geomType => GeomType.path;

  @override
  ChartView? toView(Context context) {
    return PathView(context, this);
  }
}
