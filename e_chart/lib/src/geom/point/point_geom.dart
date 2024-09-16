import 'package:e_chart/e_chart.dart';

class PointGeom extends Geom {
  PointGeom(
    super.dataSet,
    super.coordId, {
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.cacheLayer,
    super.layoutParams,
  });

  @override
  GeomType get geomType => GeomType.point;

  @override
  ChartView? toView(Context context) {
    return PointView(context, this);
  }
}
