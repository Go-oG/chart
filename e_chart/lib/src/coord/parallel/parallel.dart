import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/option/dim.dart';

import '../index.dart';

class Parallel extends Coord {
  bool expandable;
  int expandStartIndex;
  int expandCount;
  num expandWidth;

  List<ParallelAxis> axisList;

  Parallel({
    this.expandable = false,
    this.expandStartIndex = 0,
    this.expandCount = 0,
    this.expandWidth = 30,
    this.axisList = const [],
    super.direction = Direction.horizontal,
    super.id,
    super.show,
    super.toolTip,
    super.layoutParams,
    super.backgroundColor,
  });

  @override
  CoordType get type => CoordType.parallel;

  @override
  CoordView<Coord>? toCoord(Context context) {
    return ParallelCoordImpl(context, this);
  }

  @override
  List<AxisDim> get allAxisDim {
    List<AxisDim> list = [];
    each(axisList, (p0, p1) {
      list.add(AxisDim.of(Dim.y, p1));
    });
    return list;
  }

  @override
  BaseAxis getAxisConfig(AxisDim axisDim) {
    if (axisDim.dim == Dim.x) {
      throw ChartError("Only support Dim.y");
    }
    return axisList[axisDim.index];
  }
}
