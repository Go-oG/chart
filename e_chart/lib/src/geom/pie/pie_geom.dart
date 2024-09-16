import 'package:e_chart/e_chart.dart';

/// 饼图系列
class PieGeom extends Geom {
  List<SNumber> center;

  //内圆半径(<=0时为圆)
  SNumber innerRadius;

  //外圆最大半径(<=0时为圆)
  SNumber outerRadius;

  ///饼图扫过的角度(范围最大为360，如果为负数则为逆时针)
  num sweepAngle;

  //偏移角度默认为0
  double offsetAngle;

  //拐角半径 默认为0
  double corner;

  //角度间距(默认为0)
  double angleGap;

  //动画缩放扩大系数
  SNumber scaleExtend;

  //布局类型
  RoseType roseType;

  Align2 labelAlign;

  PieAnimatorStyle animatorStyle;

  ///用于实现偏移
  Fun2<RawData, num>? offsetFun;

  PieGeom(
    List<RawData> dataset, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.innerRadius = const SNumber.percent(15),
    this.outerRadius = const SNumber.percent(45),
    this.scaleExtend = const SNumber.number(16),
    this.sweepAngle = 360,
    this.offsetAngle = 0,
    this.corner = 0,
    this.roseType = RoseType.normal,
    this.angleGap = 0,
    this.labelAlign = Align2.end,
    this.animatorStyle = PieAnimatorStyle.expandScale,
    this.offsetFun,
    super.layoutParams,
    super.tooltip,
    super.animation,
    super.clip,
    super.backgroundColor,
    super.id,
    super.cacheLayer,
  }) : super(dataset, randomId());

  @override
  ChartView? toView(Context context) {
    return PieView(context, this);
  }

  @override
  DataNode toNode(RawData data) {
    var node = super.toNode(data);
    for (var pos in allPos) {
      var v = data.get2(pos.field);
      if (v is num) {
        node.value = v.toDouble();
        break;
      }
    }
    return node;
  }

  double getOffset(Context context, RawData data) {
    if (offsetFun == null) {
      return 0;
    }
    return offsetFun!.call(data).toDouble();
  }

  @override
  GeomType get geomType => GeomType.pie;
}

enum RoseType {
  normal,
  radius, //圆心角展现数据百分比，半径展示数据大小
  area // 圆心角相同 半径展示数据的大小
}

enum PieAnimatorStyle {
  expand,
  expandScale,
  originExpand,
  originExpandScale,
}
