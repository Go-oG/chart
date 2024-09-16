// 轴标签相关
import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';

class AxisLabel {
  final bool show;

  final bool inside;

  final bool? alignTick;

  //坐标轴刻度标签的显示间隔，在类目轴中有效。
  // 默认会采用标签不重叠的策略间隔显示标签。默认-1
  // 可以设置成 0 强制显示所有标签。
  // 如果设置为 1，表示『隔一个标签显示一个标签』，如果值为 2，表示隔两个标签显示一个标签，以此类推。
  final int interval;

  final double rotate;
  final double margin;
  final double padding;
  final bool? showMinLabel;
  final bool? showMaxLabel;

  ///是否隐藏重叠的标签
  final bool hideOverLap;
  final LabelStyle? style;
  final LabelStyle? minorStyle;

  final Fun2<dynamic, DynamicText>? formatter;
  final Fun3<int, int, LabelStyle?>? styleFun;
  final Fun3<int, int, LabelStyle?>? minorStyleFun;

  const AxisLabel({
    this.show = true,
    this.interval = 0,
    this.inside = false,
    this.alignTick,
    this.rotate = 0,
    this.margin = 8,
    this.padding = 0,
    this.showMinLabel,
    this.showMaxLabel,
    this.hideOverLap = true,
    this.style,
    this.formatter,
    this.styleFun,
    this.minorStyle,
    this.minorStyleFun,
  });

  AxisLabel copy({
    bool? show,
    bool? inside,
    bool? alignTick,
    int? interval,
    double? rotate,
    double? margin,
    double? padding,
    bool? showMinLabel,
    bool? showMaxLabel,
    bool? hideOverLap,
    LabelStyle? style,
    LabelStyle? minorStyle,
    Fun2<dynamic, DynamicText>? formatter,
    Fun3<int, int, LabelStyle?>? styleFun,
    Fun3<int, int, LabelStyle?>? minorStyleFun,
  }) {
    return AxisLabel(
      show: show ?? this.show,
      inside: inside ?? this.inside,
      alignTick: alignTick ?? this.alignTick,
      interval: interval ?? this.interval,
      rotate: rotate ?? this.rotate,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      showMinLabel: showMinLabel ?? this.showMinLabel,
      showMaxLabel: showMaxLabel ?? this.showMaxLabel,
      hideOverLap: hideOverLap ?? this.hideOverLap,
      style: style ?? this.style,
      formatter: formatter ?? this.formatter,
      styleFun: styleFun ?? this.styleFun,
      minorStyle: minorStyle ?? this.minorStyle,
      minorStyleFun: minorStyleFun ?? this.minorStyleFun,
    );
  }

  LabelStyle getStyle(int index, int maxIndex, AxisTheme theme) {
    if (styleFun != null) {
      return styleFun?.call(index, maxIndex) ?? LabelStyle.empty;
    }
    if (style != null) {
      return style!;
    }
    if (!theme.showLabel) {
      return LabelStyle.empty;
    }
    return LabelStyle(textStyle: TextStyle(color: theme.labelColor, fontSize: theme.labelSize.toDouble()));
  }

  LabelStyle getMinorStyle(int index, int maxIndex, AxisTheme theme) {
    if (minorStyleFun != null) {
      return minorStyleFun?.call(index, maxIndex) ?? LabelStyle.empty;
    }
    if (minorStyle != null) {
      return minorStyle!;
    }
    if (!theme.showLabel) {
      return LabelStyle.empty;
    }
    return LabelStyle(textStyle: TextStyle(color: theme.minorLabelColor, fontSize: theme.minorLabelSize.toDouble()));
  }

  @override
  int get hashCode {
    return Object.hash(
      show,
      inside,
      alignTick,
      interval,
      rotate,
      margin,
      padding,
      showMinLabel,
      showMaxLabel,
      hideOverLap,
      style,
      formatter,
      styleFun,
      minorStyle,
      minorStyleFun,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AxisLabel &&
        other.show == show &&
        other.inside == inside &&
        other.alignTick == alignTick &&
        other.interval == interval &&
        other.rotate.equal(rotate) &&
        other.margin.equal(margin) &&
        other.padding.equal(padding) &&
        other.showMinLabel == showMinLabel &&
        other.showMaxLabel == showMaxLabel &&
        other.hideOverLap == hideOverLap &&
        other.style == style &&
        other.formatter == formatter &&
        other.styleFun == styleFun &&
        other.minorStyle == minorStyle &&
        other.minorStyleFun == minorStyleFun;
  }
}
