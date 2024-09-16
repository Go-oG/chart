import 'package:e_chart/e_chart.dart';

/// 坐标轴指示器
class AxisPointer {
  final bool show;

  ///触发条件
  final TriggerOn triggerOn;
  //坐标轴指示器是否自动吸附到点上。默认自动判断
  final bool? snap;

  final LineStyle lineStyle;
  final LabelStyle labelStyle;

  const AxisPointer({
    this.show = true,
    this.snap,
    this.triggerOn = TriggerOn.moveAndClick,
    this.lineStyle = const LineStyle(),
    this.labelStyle = const LabelStyle(),
  });

  AxisPointer copy({
    bool? show,
    bool? snap,
    TriggerOn? triggerOn,
    LineStyle? lineStyle,
    LabelStyle? labelStyle,
  }) {
    return AxisPointer(
      show: show ?? this.show,
      snap: snap ?? this.snap,
      triggerOn: triggerOn ?? this.triggerOn,
      lineStyle: lineStyle ?? this.lineStyle,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  @override
  int get hashCode {
    return Object.hash(show, triggerOn, snap, lineStyle, labelStyle);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AxisPointer &&
        other.show == show &&
        other.triggerOn == triggerOn &&
        other.snap == snap &&
        other.lineStyle == lineStyle &&
        other.labelStyle == labelStyle;
  }
}
