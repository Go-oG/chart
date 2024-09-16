import 'package:e_chart/e_chart.dart';

class MainTick {
  final bool show;

  ///坐标轴刻度的显示间隔，只在类目轴中有效
  /// <=0时显示所有Tick
  /// 1 『隔一个Tick显示一个Tick』
  /// 2 隔两个Tick显示一个Tick，以此类推
  final int interval;

  /// 刻度长度
  final num length;

  ///刻度样式
  final LineStyle lineStyle;

  const MainTick({
    this.show = true,
    this.length = 8,
    this.lineStyle = const LineStyle(),
    this.interval = -1,
  });

  MainTick copy({
    bool? show,
    num? length,
    LineStyle? lineStyle,
    int? interval,
  }) {
    return MainTick(
      show: show ?? this.show,
      length: length ?? this.length,
      lineStyle: lineStyle ?? this.lineStyle,
      interval: interval ?? this.interval,
    );
  }

  @override
  int get hashCode {
    return Object.hash(show, length, lineStyle, interval);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MainTick &&
        other.show == show &&
        other.length == length &&
        other.lineStyle == lineStyle &&
        other.interval == interval;
  }
}
