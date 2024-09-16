import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class AxisLine {
  final bool show;
  final double width;
  final Color? color;
  final List<num> dash;
  final List<BoxShadow> shadow;
  final AxisSymbol symbol; //控制是否显示箭头
  final Size symbolSize;
  final Offset symbolOffset;

  const AxisLine({
    this.width = 1,
    this.dash = const [],
    this.shadow = const [],
    this.show = true,
    this.symbol = AxisSymbol.none,
    this.symbolSize = const Size.square(16),
    this.symbolOffset = Offset.zero,
    this.color,
  });

  AxisLine copy({
    double? width,
    List<num>? dash,
    List<BoxShadow>? shadow,
    bool? show,
    AxisSymbol? symbol,
    Size? symbolSize,
    Offset? symbolOffset,
    Color? color,
  }) {
    return AxisLine(
      width: width ?? this.width,
      dash: dash ?? this.dash,
      shadow: shadow ?? this.shadow,
      show: show ?? this.show,
      symbol: symbol ?? this.symbol,
      symbolSize: symbolSize ?? this.symbolSize,
      symbolOffset: symbolOffset ?? this.symbolOffset,
      color: color ?? this.color,
    );
  }

  LineStyle getStyle(AxisTheme theme) {
    if (!show) {
      return LineStyle.empty;
    }
    Color? color;
    if (this.color != null) {
      color = this.color;
    } else {
      color = theme.getAxisLineColor(0);
    }

    if (color == null) {
      return LineStyle.empty;
    }
    return LineStyle(color: color, dash: dash, shadow: shadow, smooth: 0);
  }

  double getLength() {
    if (!show) {
      return 0;
    }
    if (width <= 0) {
      return 0;
    }
    return width.toDouble();
  }

  @override
  int get hashCode {
    return Object.hash(show, width, dash, shadow, symbol, symbolSize, symbolOffset, color);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AxisLine &&
        other.show == show &&
        other.width == width &&
        other.dash == dash &&
        other.shadow == shadow &&
        other.symbol == symbol &&
        other.symbolSize == symbolSize &&
        other.symbolOffset == symbolOffset &&
        other.color == color;
  }
}
