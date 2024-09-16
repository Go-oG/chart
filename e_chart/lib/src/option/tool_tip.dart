import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///提示框
class ToolTip {
  final bool show;
  final Trigger trigger;
  final TriggerOn triggerOn;
  final bool alwaysShowContent;

  ///鼠标是否可进入提示框浮层中，默认为false，如需详情内交互，如添加链接，按钮，可设置为 true。
  final bool enterAble;

  ///是否将 tooltip 框限制在图表的区域内
  final bool confine;

  ///提示框浮层的移动动画过渡时间 设置为<=0 的时候会紧跟着鼠标移动
  final int transitionDuration;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;

  ///浮层位置，当不设置时跟随鼠标位置
  final List<SNumber>? position;
  final EdgeInsets padding;
  final BoxDecoration decoration;
  final LabelStyle labelStyle;
  final ToolTipOrder order;

  final Fun3<MenuItem, int, Widget>? itemBuilder;

  const ToolTip({
    this.show = true,
    this.trigger = Trigger.item,
    this.alwaysShowContent = false,
    this.triggerOn = TriggerOn.moveAndClick,
    this.enterAble = false,
    this.confine = false,
    this.transitionDuration = 400,
    this.position,
    this.order = ToolTipOrder.geomAsc,
    this.decoration = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, blurStyle: BlurStyle.solid)],
    ),
    this.padding = const EdgeInsets.all(5),
    this.labelStyle = const LabelStyle(),
    this.minHeight,
    this.minWidth = 300,
    this.maxHeight = 400,
    this.maxWidth,
    this.itemBuilder,
  });

  ToolTip copy({
    bool? show,
    Trigger? trigger,
    bool? alwaysShowContent,
    TriggerOn? triggerOn,
    bool? enterAble,
    bool? confine,
    int? transitionDuration,
    List<SNumber>? position,
    ToolTipOrder? order,
    BoxDecoration? decoration,
    EdgeInsets? padding,
    LabelStyle? labelStyle,
    double? minHeight,
    double? minWidth,
    double? maxHeight,
    double? maxWidth,
    Fun3<MenuItem, int, Widget>? itemBuilder,
  }) {
    return ToolTip(
      show: show ?? this.show,
      trigger: trigger ?? this.trigger,
      alwaysShowContent: alwaysShowContent ?? this.alwaysShowContent,
      triggerOn: triggerOn ?? this.triggerOn,
      enterAble: enterAble ?? this.enterAble,
      confine: confine ?? this.confine,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      position: position ?? this.position,
      order: order ?? this.order,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      labelStyle: labelStyle ?? this.labelStyle,
      minHeight: minHeight ?? this.minHeight,
      minWidth: minWidth ?? this.minWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      itemBuilder: itemBuilder ?? this.itemBuilder,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      show,
      trigger,
      triggerOn,
      alwaysShowContent,
      enterAble,
      confine,
      transitionDuration,
      position,
      order,
      decoration,
      padding,
      labelStyle,
      minHeight,
      minWidth,
      maxHeight,
      maxWidth,
      itemBuilder,
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
    return other is ToolTip &&
        other.show == show &&
        other.trigger == trigger &&
        other.triggerOn == triggerOn &&
        other.alwaysShowContent == alwaysShowContent &&
        other.enterAble == enterAble &&
        other.confine == confine &&
        other.transitionDuration == transitionDuration &&
        listEquals(other.position, position) &&
        other.order == order &&
        other.decoration == decoration &&
        other.padding == padding &&
        other.labelStyle == labelStyle &&
        other.minHeight == minHeight &&
        other.minWidth == minWidth &&
        other.maxHeight == maxHeight &&
        other.maxWidth == maxWidth;
  }
}

enum ToolTipOrder {
  geomAsc,
  geomDesc,
  valueAsc,
  valueDesc,
}
