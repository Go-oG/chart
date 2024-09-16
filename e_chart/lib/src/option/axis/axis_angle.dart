import 'package:e_chart/e_chart.dart';

///极坐标-角度轴
class AngleAxis extends BaseAxis {
  /// 起始刻度的角度，默认为90度(圆心的正上方为0度)
  final double offsetAngle;

  ///是否顺时针
  final bool clockwise;
  final double sweepAngle;

  const AngleAxis({
    this.offsetAngle = 0,
    this.sweepAngle = 360,
    this.clockwise = true,
    super.show,
    super.type = AxisType.value,
    super.min,
    super.max,
    super.splitNumber,
    super.logBase,
    super.interval,
    super.maxInterval,
    super.minInterval,
    super.categoryList,
    super.timeRange,
    super.timeType,
    super.axisName,
    super.axisLine,
    super.axisLabel,
    super.splitLine,
    super.splitArea,
    super.axisTick,
    super.axisPointer,
    super.alignTicks,
    super.categoryCenter = false,
  }) : super(inverse: false);

  AngleAxis copy({
    double? offsetAngle,
    bool? clockwise,
    double? sweepAngle,
    bool? show,
    AxisType? type,
    List<String>? categoryList,
    bool? categoryCenter,
    bool? alignTicks,
    TimeType? timeType,
    Pair<DateTime, DateTime>? timeRange,
    num? min,
    num? max,
    int? splitNumber,
    num? minInterval,
    num? maxInterval,
    num? interval,
    int? logBase,
    bool? inverse,
    AxisName? axisName,
    AxisLine? axisLine,
    AxisLabel? axisLabel,
    AxisTick? axisTick,
    SplitLine? splitLine,
    SplitArea? splitArea,
    AxisPointer? axisPointer,
  }) {
    return AngleAxis(
      offsetAngle: offsetAngle ?? this.offsetAngle,
      clockwise: clockwise ?? this.clockwise,
      sweepAngle: sweepAngle ?? this.sweepAngle,
      show: show ?? this.show,
      type: type ?? this.type,
      categoryList: categoryList ?? this.categoryList,
      categoryCenter: categoryCenter ?? this.categoryCenter,
      alignTicks: alignTicks ?? this.alignTicks,
      timeType: timeType ?? this.timeType,
      timeRange: timeRange ?? this.timeRange,
      min: min ?? this.min,
      max: max ?? this.max,
      splitNumber: splitNumber ?? this.splitNumber,
      minInterval: minInterval ?? this.minInterval,
      maxInterval: maxInterval ?? this.maxInterval,
      interval: interval ?? this.interval,
      logBase: logBase ?? this.logBase,
      axisName: axisName ?? this.axisName,
      axisLine: axisLine ?? this.axisLine,
      axisLabel: axisLabel ?? this.axisLabel,
      axisTick: axisTick ?? this.axisTick,
      splitLine: splitLine ?? this.splitLine,
      splitArea: splitArea ?? this.splitArea,
    );
  }

}
