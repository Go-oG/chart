import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///引导线
class GuideLine {
  final bool show;
  final num length;
  final LineStyle style;
  final List<num> gap; //线和文字之间的距离

  const GuideLine({
    this.show = true,
    this.length = 16,
    this.style = const LineStyle(color: Colors.black),
    this.gap = const [4, 0],
  });

  GuideLine copy({
    bool? show,
    double? length,
    LineStyle? style,
    List<num>? gap,
  }) {
    return GuideLine(
      show: show ?? this.show,
      length: length ?? this.length,
      style: style ?? this.style,
      gap: gap ?? this.gap,
    );
  }

  @override
  int get hashCode {
    return Object.hash(show, length, style, gap);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GuideLine &&
        other.show == show &&
        other.length == length &&
        other.style == style &&
        listEquals(other.gap, gap);
  }
}
