import 'package:e_chart/e_chart.dart';

class AreaGeom extends PathGeom {
  AreaGeom(
    super.dataSet,
    super.coordId, {
    super.smooth,
    super.dashList,
    super.disDiff,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.cacheLayer,
    super.layoutParams,
  });

  @override
  ChartView? toView(Context context)=>AreaView(context, this);

  @override
  GeomType get geomType => GeomType.area;
}
