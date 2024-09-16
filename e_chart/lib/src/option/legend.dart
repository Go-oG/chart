import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Legend {
  final List<LegendItem>? data;
  final bool show;

  ///是否允许滚动 如果允许则将不会使用Wrap,否则会使用Wrap
  final bool scroll;
  final Align2 mainAlign;
  final Align2 crossAlign;

  final Offset offset;
  final Direction direction;
  final Position labelPosition;
  final WrapAlignment vAlign;
  final WrapAlignment hAlign;
  final double hGap;
  final double vGap;
  final bool allowSelectMulti;
  final AreaStyle inactiveStyle;
  final LineStyle inactiveBorderStyle;
  final AnimateOption? animator;
  final BoxDecoration? decoration;
  final EdgeInsets padding;
  final TriggerOn triggerOn;

  const Legend({
    this.show = true,
    this.scroll = false,
    this.mainAlign = Align2.start,
    this.crossAlign = Align2.start,
    this.data,
    this.labelPosition = Position.right,
    this.vAlign = WrapAlignment.start,
    this.hAlign = WrapAlignment.start,
    this.offset = Offset.zero,
    this.direction = Direction.horizontal,
    this.hGap = 10,
    this.vGap = 10,
    this.allowSelectMulti = true,
    this.inactiveStyle = const AreaStyle(color: Color(0xFFCCCCCC)),
    this.inactiveBorderStyle = LineStyle.empty,
    this.animator,
    this.decoration,
    this.padding = EdgeInsets.zero,
    this.triggerOn = TriggerOn.click,
  });

  Legend copy({
    bool? show,
    bool? scroll,
    Align2? mainAlign,
    Align2? crossAlign,
    List<LegendItem>? data,
    Position? labelPosition,
    WrapAlignment? vAlign,
    WrapAlignment? hAlign,
    Offset? offset,
    Direction? direction,
    double? hGap,
    double? vGap,
    bool? allowSelectMulti,
    AreaStyle? inactiveStyle,
    LineStyle? inactiveBorderStyle,
    AnimateOption? animator,
    BoxDecoration? decoration,
    EdgeInsets? padding,
    TriggerOn? triggerOn,
  }) {
    return Legend(
      show: show ?? this.show,
      scroll: scroll ?? this.scroll,
      mainAlign: mainAlign ?? this.mainAlign,
      crossAlign: crossAlign ?? this.crossAlign,
      data: data ?? this.data,
      labelPosition: labelPosition ?? this.labelPosition,
      vAlign: vAlign ?? this.vAlign,
      hAlign: hAlign ?? this.hAlign,
      offset: offset ?? this.offset,
      direction: direction ?? this.direction,
      hGap: hGap ?? this.hGap,
      vGap: vGap ?? this.vGap,
      allowSelectMulti: allowSelectMulti ?? this.allowSelectMulti,
      inactiveStyle: inactiveStyle ?? this.inactiveStyle,
      inactiveBorderStyle: inactiveBorderStyle ?? this.inactiveBorderStyle,
      animator: animator ?? this.animator,
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      triggerOn: triggerOn ?? this.triggerOn,
    );
  }

  const Legend.empty()
      : show = false,
        scroll = false,
        mainAlign = Align2.start,
        crossAlign = Align2.start,
        data = const [],
        labelPosition = Position.right,
        vAlign = WrapAlignment.start,
        hAlign = WrapAlignment.start,
        offset = Offset.zero,
        direction = Direction.horizontal,
        vGap = 0,
        hGap = 0,
        allowSelectMulti = true,
        inactiveStyle = AreaStyle.empty,
        inactiveBorderStyle = LineStyle.empty,
        animator = null,
        decoration = null,
        padding = EdgeInsets.zero,
        triggerOn = TriggerOn.click;

  @override
  int get hashCode {
    return Object.hash(
      show,
      scroll,
      mainAlign,
      crossAlign,
      data,
      labelPosition,
      vAlign,
      hAlign,
      offset,
      direction,
      vGap,
      hGap,
      allowSelectMulti,
      inactiveStyle,
      inactiveBorderStyle,
      animator,
      decoration,
      padding,
      triggerOn,
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
    return other is Legend &&
        other.show == show &&
        other.scroll == scroll &&
        other.mainAlign == mainAlign &&
        other.crossAlign == crossAlign &&
        listEquals(other.data, data) &&
        other.labelPosition == labelPosition &&
        other.vAlign == vAlign &&
        other.hAlign == hAlign &&
        other.offset == offset &&
        other.direction == direction &&
        other.vGap == vGap &&
        other.hGap == hGap &&
        other.allowSelectMulti == allowSelectMulti &&
        other.inactiveStyle == inactiveStyle &&
        other.inactiveBorderStyle == inactiveBorderStyle &&
        other.animator == animator &&
        other.decoration == decoration &&
        other.padding == padding &&
        other.triggerOn == triggerOn;
  }
}
