import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class ChartTitle {
  final bool show;
  final Align2 mainAlign;
  final Align2 crossAlign;
  final Offset offset;
  final String text;
  final String subText;
  final double gap;
  final bool triggerEvent;
  final Align2 textAlign;
  final Align2 textVerticalAlign;
  final EdgeInsets padding;
  final LabelStyle textStyle;
  final LabelStyle subTextStyle;
  final Decoration decoration;

  const ChartTitle({
    this.show = false,
    this.mainAlign = Align2.start,
    this.crossAlign = Align2.start,
    this.offset = const Offset(8, 8),
    this.text = '',
    this.subText = '',
    this.gap = 10,
    this.triggerEvent = false,
    this.textAlign = Align2.center,
    this.textVerticalAlign = Align2.center,
    this.padding = const EdgeInsets.all(5),
    this.textStyle = const LabelStyle(),
    this.subTextStyle = const LabelStyle(),
    this.decoration = const BoxDecoration(),
  });

  ChartTitle copy({
    bool? show,
    Align2? mainAlign,
    Align2? crossAlign,
    Offset? offset,
    String? text,
    String? subText,
    double? gap,
    bool? triggerEvent,
    Align2? textAlign,
    Align2? textVerticalAlign,
    EdgeInsets? padding,
    LabelStyle? textStyle,
    LabelStyle? subTextStyle,
    BoxDecoration? decoration,
  }) {
    return ChartTitle(
        show: show ?? this.show,
        mainAlign: mainAlign ?? this.mainAlign,
        crossAlign: crossAlign ?? this.crossAlign,
        offset: offset ?? this.offset,
        text: text ?? this.text,
        subText: subText ?? this.subText,
        gap: gap ?? this.gap,
        triggerEvent: triggerEvent ?? this.triggerEvent,
        textAlign: textAlign ?? this.textAlign,
        textVerticalAlign: textVerticalAlign ?? this.textVerticalAlign,
        padding: padding ?? this.padding,
        textStyle: textStyle ?? this.textStyle,
        subTextStyle: subTextStyle ?? this.subTextStyle,
        decoration: decoration ?? this.decoration);
  }

  @override
  int get hashCode {
    return Object.hash(
      show,
      mainAlign,
      crossAlign,
      offset,
      text,
      subText,
      gap,
      triggerEvent,
      textAlign,
      textVerticalAlign,
      padding,
      textStyle,
      subTextStyle,
      decoration,
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
    return other is ChartTitle &&
        other.show == show &&
        other.mainAlign == mainAlign &&
        other.crossAlign == crossAlign &&
        other.offset == offset &&
        other.text == text &&
        other.subText == subText &&
        other.gap == gap &&
        other.triggerEvent == triggerEvent &&
        other.textAlign == textAlign &&
        other.textVerticalAlign == textVerticalAlign &&
        other.padding == padding &&
        other.textStyle == textStyle &&
        other.subTextStyle == subTextStyle &&
        other.decoration == decoration;
  }
}
