import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///框选配置
class Brush {
  final bool enable;
  final BrushType type;
  final bool supportMulti;

  ///supportMulti 为 false 的情况下，是否支持『单击清除所有选框』。
  final bool removeOnClick;
  final bool allowMove;

  ///默认情况，刷选或者移动选区的时候，会不断得发brushSelected事件，从而告诉外界选中的内容。
  /// 但是频繁的事件可能导致性能问题，或者动画效果很差。所以 brush 组件提供了 brush.throttleType，brush.throttleDelay 来解决这个问题。
  /// true：表示只有停止动作了（即一段时间没有操作了），才会触发事件。时间阈值由 brush.throttleDelay 指定。
  /// false：表示按照一定的频率触发事件，时间间隔由 brush.throttleDelay 指定。
  final bool throttleDebounce;
  final int throttleDelay;

  final LineStyle? borderStyle;
  final AreaStyle areaStyle;

  const Brush({
    this.enable = false,
    this.type = BrushType.rect,
    this.supportMulti = true,
    this.allowMove = true,
    this.borderStyle,
    this.throttleDebounce = false,
    this.throttleDelay = 0,
    this.removeOnClick = true,
    this.areaStyle = const AreaStyle(color: Color(0x4D2196F3)),
  });

  Brush copy({
    bool? enable,
    BrushType? type,
    bool? supportMulti,
    bool? allowMove,
    LineStyle? borderStyle,
    bool? throttleDebounce,
    int? throttleDelay,
    bool? removeOnClick,
    AreaStyle? areaStyle,
  }) {
    return Brush(
      enable: enable ?? this.enable,
      type: type ?? this.type,
      supportMulti: supportMulti ?? this.supportMulti,
      allowMove: allowMove ?? this.allowMove,
      borderStyle: borderStyle ?? this.borderStyle,
      throttleDebounce: throttleDebounce ?? this.throttleDebounce,
      throttleDelay: throttleDelay ?? this.throttleDelay,
      removeOnClick: removeOnClick ?? this.removeOnClick,
      areaStyle: areaStyle ?? this.areaStyle,
    );
  }

  @override
  int get hashCode {
    return Object.hash(
      enable,
      type,
      supportMulti,
      removeOnClick,
      allowMove,
      throttleDebounce,
      throttleDelay,
      borderStyle,
      areaStyle,
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
    return other is Brush &&
        other.enable == enable &&
        other.type == type &&
        other.supportMulti == supportMulti &&
        other.removeOnClick == removeOnClick &&
        other.allowMove == allowMove &&
        other.throttleDebounce == throttleDebounce &&
        other.throttleDelay == throttleDelay &&
        other.borderStyle == borderStyle &&
        other.areaStyle == areaStyle;
  }
}

enum BrushType {
  rect,
  polygon,
  vertical,
  horizontal,
}
