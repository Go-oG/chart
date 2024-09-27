import 'package:e_chart/e_chart.dart';

class AreaGeom extends PointGeom {
  double smooth = 0;

  AreaGeom(
    super.dataSet,
    super.coordId, {
    this.smooth = 0,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.cacheLayer,
    super.layoutParams,
  });

  @override
  ChartView? toView(Context context) {
    return AreaView(context, this);
  }

  @override
  GeomType get geomType => GeomType.area;
}
