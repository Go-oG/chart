import '../../../e_chart.dart';

///直线
class PathGeom extends PointGeom {
  double smooth = 0;
  List<double>? dashList;

  double disDiff = 2;

  PathGeom(
    super.dataSet,
    super.scope, {
    this.smooth = 0,
    this.dashList,
    this.disDiff = 2,
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
