import 'package:e_chart/e_chart.dart';
import '../index.dart';

class Grid extends Coord {
  ///grid区域是否包含坐标轴的刻度标签
  bool containLabel;

  late List<XAxis> xAxisList;
  late List<YAxis> yAxisList;

  Grid({
    List<XAxis>? xAxisList,
    List<YAxis>? yAxisList,
    this.containLabel = false,
    super.brush,
    super.layoutParams,
    super.toolTip,
    super.backgroundColor,
    super.id,
    super.show,
    super.freeDrag,
    super.freeLongPress,
  }) {
    this.xAxisList = xAxisList ?? [const XAxis(type: AxisType.category)];
    this.yAxisList = yAxisList ?? [const YAxis()];
  }

  @override
  CoordType get type => CoordType.grid;

  @override
  CoordView<Coord>? toCoord(Context context)=>GridCoordImpl(context, this);

  @override
  List<AxisDim> get allAxisDim {
    List<AxisDim> list = [];
    each(xAxisList, (p0, p1) {
      list.add(AxisDim.of(Dim.x, p1));
    });
    each(yAxisList, (p0, p1) {
      list.add(AxisDim.of(Dim.y, p1));
    });
    return list;
  }

  @override
  BaseAxis getAxisConfig(AxisDim axisDim) {
    if (axisDim.dim == Dim.x) {
      return xAxisList[axisDim.index];
    }
    return yAxisList[axisDim.index];
  }
}
