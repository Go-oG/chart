import 'package:e_chart/e_chart.dart';

///坐标轴在grid区域中的分隔线
class SplitLine {
  final bool show;
  final int interval;

  final LineStyle? style;
  final Fun4<dynamic, int, int, LineStyle>? styleFun;

  final LineStyle? minorStyle;
  final Fun4<dynamic, int, int, LineStyle>? minorStyleFun;

  const SplitLine({
    this.show = false,
    this.interval = -1,
    this.style,
    this.styleFun,
    this.minorStyle,
    this.minorStyleFun,
  });

  SplitLine copy({
    bool? show,
    int? interval,
    LineStyle? style,
    Fun4<dynamic, int, int, LineStyle>? styleFun,
    LineStyle? minorStyle,
    Fun4<dynamic, int, int, LineStyle>? minorStyleFun,
  }) {
    return SplitLine(
      show: show ?? this.show,
      interval: interval ?? this.interval,
      style: style ?? this.style,
      styleFun: styleFun ?? this.styleFun,
      minorStyle: minorStyle ?? this.minorStyle,
      minorStyleFun: minorStyleFun ?? this.minorStyleFun,
    );
  }

  LineStyle getStyle(dynamic data, int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return LineStyle.empty;
    }
    LineStyle? style;
    if (styleFun != null) {
      style = styleFun?.call(data, index, maxIndex);
    } else {
      if (this.style != null) {
        style = this.style;
      } else {
        style = theme.getSplitLineStyle(index);
      }
    }
    return style ?? LineStyle.empty;
  }

  bool get isEnable {
    if (!show) {
      return false;
    }
    if (styleFun != null || minorStyleFun != null) {
      return true;
    }

    if (style != null && style!.canDraw) {
      return true;
    }
    if (minorStyle != null && minorStyle!.canDraw) {
      return true;
    }
    return false;
  }

  LineStyle getMinorStyle(dynamic data, int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return LineStyle.empty;
    }
    LineStyle? style;
    if (minorStyleFun != null) {
      style = minorStyleFun?.call(data, index, maxIndex);
    } else {
      if (minorStyle != null) {
        style = minorStyle;
      } else {
        style = theme.getSplitLineStyle(index);
      }
    }
    return style ?? LineStyle.empty;
  }

  @override
  int get hashCode {
    return Object.hash(show, interval, style, styleFun, minorStyle, minorStyleFun);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SplitLine &&
        other.show == show &&
        other.interval == interval &&
        other.style == style &&
        other.styleFun == styleFun &&
        other.minorStyle == minorStyle &&
        other.minorStyleFun == minorStyleFun;
  }
}
