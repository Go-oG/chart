import 'package:e_chart/e_chart.dart';

///笛卡尔坐标轴
class GridAxis extends BaseAxis {
  final Align2 position;
  final double offset;

  const GridAxis({
    this.position = Align2.end,
    this.offset = 8,
    super.alignTicks,
    super.show,
    super.type,
    super.min,
    super.max,
    super.splitNumber,
    super.logBase,
    super.interval,
    super.maxInterval,
    super.minInterval,
    super.inverse,
    super.categoryList,
    super.categoryCenter,
    super.timeRange,
    super.timeType,
    super.axisName,
    super.axisLine,
    super.axisLabel,
    super.splitLine,
    super.splitArea,
    super.axisTick,
    super.axisPointer,
  });

  GridAxis copy({
    Align2? position,
    double? offset,
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
    return GridAxis(
      position: position ?? this.position,
      offset: offset ?? this.offset,
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
      inverse: inverse ?? this.inverse,
      axisName: axisName ?? this.axisName,
      axisLine: axisLine ?? this.axisLine,
      axisLabel: axisLabel ?? this.axisLabel,
      axisTick: axisTick ?? this.axisTick,
      splitLine: splitLine ?? this.splitLine,
      splitArea: splitArea ?? this.splitArea,
    );
  }

  @override
  int get hashCode {
    return Object.hashAll([
      position,
      offset,
      show,
      type,
      categoryCenter,
      categoryList,
      timeType,
      timeRange,
      min,
      max,
      splitNumber,
      minInterval,
      maxInterval,
      interval,
      logBase,
      inverse,
      alignTicks,
      axisName,
      axisLine,
      axisLabel,
      axisTick,
      splitLine,
      splitArea,
      axisPointer
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GridAxis &&
        other.position == position &&
        other.offset == offset &&
        other.show == show &&
        other.type == type &&
        other.categoryCenter == categoryCenter &&
        other.categoryList == categoryList &&
        other.timeType == timeType &&
        other.timeRange == timeRange &&
        other.min == min &&
        other.max == max &&
        other.splitNumber == splitNumber &&
        other.minInterval == minInterval &&
        other.maxInterval == maxInterval &&
        other.interval == interval &&
        other.logBase == logBase &&
        other.inverse == inverse &&
        other.alignTicks == alignTicks &&
        other.axisName == axisName &&
        other.axisLine == axisLine &&
        other.axisLabel == axisLabel &&
        other.axisTick == axisTick &&
        other.splitLine == splitLine &&
        other.splitArea == splitArea &&
        other.axisPointer == axisPointer;
  }
}
