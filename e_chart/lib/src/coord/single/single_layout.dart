import 'package:e_chart/e_chart.dart';

///用于包装单个View
class SingleCoord extends CoordView {
  SingleCoord(Context context, String id) : super(context, SingleConfig(id: id));

  @override
  int get dimCount => 0;

  @override
  int getDimAxisCount(Dim dim) => 0;

  @override
  double convert(AxisDim dim, double ratio) {
    return 0;
  }

  double convert2(AxisDim dim, dynamic value) {
    return 0;
  }
}

class SingleConfig extends Coord {
  SingleConfig({
    super.toolTip,
    super.backgroundColor,
    super.id,
    super.show,
  }) : super(layoutParams: LayoutParams.matchAll());

  @override
  CoordType get type => CoordType.custom;

  @override
  List<AxisDim> get allAxisDim => const [];

  @override
  BaseAxis getAxisConfig(AxisDim axisDim) {
    throw UnimplementedError();
  }
}

class SingleCoordConfig extends Coord {
  SingleCoordConfig({super.show, super.id});

  @override
  CoordType get type => CoordType.custom;

  @override
  bool operator ==(Object other) => other is SingleCoordConfig && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  List<AxisDim> get allAxisDim => const [];

  @override
  BaseAxis getAxisConfig(AxisDim axisDim) {
    throw UnimplementedError();
  }
}
