import '../index.dart';

///雷达图坐标轴
class RadarAxis extends BaseAxis {
 const RadarAxis({
    super.show,
    super.axisName,
    super.min,
    super.max,
    super.splitNumber,
    super.logBase,
    super.interval,
    super.maxInterval,
    super.minInterval,
    super.timeType,
    super.axisLabel,
    super.axisLine,
    super.alignTicks,
    super.axisPointer,
    super.axisTick,
    super.categoryCenter,
    super.inverse,
    super.splitArea,
    super.splitLine,
  }) : super(type: AxisType.value, categoryList: const [], timeRange: null);


 RadarAxis copy({
    bool? show,
    bool? categoryCenter,
    bool? alignTicks,
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
    return RadarAxis(
       show: show ?? this.show,
       categoryCenter: categoryCenter ?? this.categoryCenter,
       alignTicks: alignTicks ?? this.alignTicks,
       min: min ?? this.min,
       max: max ?? this.max,
       splitNumber: splitNumber ?? this.splitNumber,
       minInterval: minInterval ?? this.minInterval,
       maxInterval: maxInterval ?? this.maxInterval,
       interval: interval ?? this.interval,
       logBase: logBase ?? this.logBase,
       inverse: inverse ?? this.inverse,
       axisName: axisName ?? this.axisName,
       axisLine: axisLine ?? this.axisLine,
       axisLabel: axisLabel ?? this.axisLabel,
       axisTick: axisTick ?? this.axisTick,
       splitLine: splitLine ?? this.splitLine,
       splitArea: splitArea ?? this.splitArea,
    );
 }


}
