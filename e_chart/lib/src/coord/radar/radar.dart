import 'package:e_chart/e_chart.dart';
import '../index.dart';

///雷达图坐标系
class Radar extends CircleCoord {
  List<RadarAxis> indicator;

  double offsetAngle;
  int splitNumber;
  bool silent;
  bool clockwise;
  RadarShape shape;

  ///雷达图将忽略掉label 和Tick
  AxisName? axisName;

  late AxisLine axisLine;
  late SplitLine splitLine;
  late SplitArea splitArea;

  ///坐标轴指示器
  AxisPointer? axisPointer;

  Fun2<RadarAxis, LabelStyle>? labelStyleFun;

  Radar({
    required this.indicator,
    this.offsetAngle = 0,
    this.splitNumber = 5,
    this.shape = RadarShape.polygon,
    this.silent = false,
    this.clockwise = true,
    this.labelStyleFun,
    super.center,
    super.radius,
    super.toolTip,
    super.layoutParams,
    super.backgroundColor,
    super.id,
    super.show,
    this.axisName,
    AxisLine? axisLine,
    SplitLine? splitLine,
    SplitArea? splitArea,
    this.axisPointer,
  }) {
    this.axisLine = axisLine ?? AxisLine();
    this.splitLine = splitLine ?? SplitLine();
    this.splitArea = splitArea ?? SplitArea();
  }

  @override
  CoordType get type => CoordType.radar;

  @override
  CoordView<Coord>? toCoord(Context context) {
    return RadarCoordImpl(context, this);
  }

  @override
  List<AxisDim> get allAxisDim {
    List<AxisDim> list = [];
    each(indicator, (p0, p1) {
      list.add(AxisDim.of(Dim.y, p1));
    });
    return list;
  }

  @override
  BaseAxis getAxisConfig(AxisDim axisDim) {
    if (axisDim.dim == Dim.y) {
      return indicator[axisDim.index];
    }
    throw ChartError('UnSupport Dim.x');
  }
}

/// 雷达图样式
enum RadarShape { circle, polygon }

enum RadarAnimatorStyle { scale, rotate, scaleAndRotate }
