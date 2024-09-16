import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class MarkLine {
  final MarkPoint start;
  final MarkPoint end;
  final bool touch;
  final LineStyle lineStyle;
  final int precision; //精度

  const MarkLine(
    this.start,
    this.end, {
    this.touch = false,
    this.lineStyle = const LineStyle(dash: [4, 8]),
    this.precision = 2,
  });

  MarkLine copy({
    MarkPoint? start,
    MarkPoint? end,
    bool? touch,
    LineStyle? lineStyle,
    int? precision,
  }) {
    return MarkLine(
      start ?? this.start,
      end ?? this.end,
      touch: touch ?? this.touch,
      lineStyle: lineStyle ?? this.lineStyle,
      precision: precision ?? this.precision,
    );
  }

  void draw(
    Canvas2 canvas,
    Paint paint,
    Offset start,
    Offset end, {
    DynamicText? startText,
    DynamicText? endText,
  }) {
    lineStyle.drawPolygon(canvas, paint, [start, end]);
    this.start.draw(canvas, paint, start);
    this.end.draw(canvas, paint, end);
  }

  @override
  int get hashCode {
    return Object.hash(start, end, touch, lineStyle, precision);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is MarkLine &&
        other.start == start &&
        other.end == end &&
        other.touch == touch &&
        other.lineStyle == lineStyle &&
        other.precision == precision;
  }
}

class MarkLineNode {
  final MarkLine line;
  final MarkPointNode start;
  final MarkPointNode end;

  const MarkLineNode(this.line, this.start, this.end);
}
