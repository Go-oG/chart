import 'package:e_chart/e_chart.dart';

import '../index.dart';

///极坐标系
///一个极坐标系只能包含一个径向轴和一个角度轴
class Polar extends CircleCoord {
  late AngleAxis angleAxis = AngleAxis();
  late RadiusAxis radiusAxis = RadiusAxis();
  bool silent;

  Polar({
    super.radius,
    super.center,
    RadiusAxis? radiusAxis,
    AngleAxis? angleAxis,
    this.silent = true,
    super.toolTip,
    super.layoutParams,
    super.backgroundColor,
    super.id,
    super.show,
  }) {
    if (radiusAxis != null) {
      this.radiusAxis = radiusAxis;
    }
    if (angleAxis != null) {
      this.angleAxis = angleAxis;
    }
  }

  @override
  CoordType get type => CoordType.polar;

  @override
  CoordView<Coord>? toCoord(Context context) {
    return PolarCoordImpl(context, this);
  }

  @override
  List<AxisDim> get allAxisDim {
    return [AxisDim.of(Dim.x, 0), AxisDim.of(Dim.y, 0)];
  }

  @override
  BaseAxis getAxisConfig(AxisDim axisDim) {
    if (axisDim.dim == Dim.y) {
      return radiusAxis;
    }
    return angleAxis;
  }
}
