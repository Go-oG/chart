import 'package:e_chart/e_chart.dart';

class AreaSeries extends Geom {
  double smooth = 0;
  AreaSeries(super.dataSet, super.scope);

  @override
  ChartView? toView(Context context) {
    return AreaView(context, this);
  }

  @override
  GeomType get geomType => GeomType.area;
}
