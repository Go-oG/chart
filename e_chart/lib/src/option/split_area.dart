import 'package:e_chart/e_chart.dart';

class SplitArea {
  final bool show;
  final int interval;
  final AreaStyle? style;
  final Fun3<int, int, AreaStyle>? splitAreaFun;

  const SplitArea({
    this.show = false,
    this.interval = -1,
    this.style,
    this.splitAreaFun,
  });

  SplitArea copy({
    bool? show,
    int? interval,
    AreaStyle? style,
    Fun3<int, int, AreaStyle>? splitAreaFun,
  }) {
    return SplitArea(
      show: show ?? this.show,
      interval: interval ?? this.interval,
      style: style ?? this.style,
      splitAreaFun: splitAreaFun ?? this.splitAreaFun,
    );
  }

  AreaStyle getStyle(int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return AreaStyle.empty;
    }
    AreaStyle? style;
    if (splitAreaFun != null) {
      style = splitAreaFun?.call(index, maxIndex);
    } else {
      if (this.style != null) {
        style = this.style;
      } else {
        style = theme.getSplitAreaStyle(index);
      }
    }
    return style ?? AreaStyle.empty;
  }

  @override
  int get hashCode {
    return Object.hash(show, interval, style, splitAreaFun);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SplitArea &&
        other.show == show &&
        other.interval == interval &&
        other.style == style &&
        other.splitAreaFun == splitAreaFun;
  }
}
