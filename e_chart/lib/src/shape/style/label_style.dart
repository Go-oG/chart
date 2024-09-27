import 'dart:ui' as ui;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class LabelStyle extends CStyle {
  static const LabelStyle empty = LabelStyle(show: false);
  final bool show;
  final double rotate;
  final TextStyle textStyle;
  final int? maxLines;
  final BoxDecoration? decoration;
  final OverFlow overFlow;
  final String ellipsis;
  final double lineMargin;
  final GuideLine? guideLine;
  final double minAngle; //对应在扇形形状中小于好多时则不显示

  const LabelStyle({
    this.show = true,
    this.rotate = 0,
    this.maxLines,
    this.textStyle = const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13, fontWeight: FontWeight.normal),
    this.decoration,
    this.overFlow = OverFlow.notDraw,
    this.ellipsis = '',
    this.guideLine,
    this.lineMargin = 4,
    this.minAngle = 0,
  });

  LabelStyle copy({
    bool? show,
    double? rotate,
    TextStyle? textStyle,
    BoxDecoration? decoration,
    OverFlow? overFlow,
    String? ellipsis,
    GuideLine? guideLine,
    double? lineMargin,
    double? minAngle,
    int? maxLines,
    TextTransborder? transborder,
  }) {
    return LabelStyle(
      show: show ?? this.show,
      rotate: rotate ?? this.rotate,
      textStyle: textStyle ?? this.textStyle,
      decoration: decoration ?? this.decoration,
      overFlow: overFlow ?? this.overFlow,
      ellipsis: ellipsis ?? this.ellipsis,
      guideLine: guideLine ?? this.guideLine,
      lineMargin: lineMargin ?? this.lineMargin,
      maxLines: maxLines ?? this.maxLines,
      minAngle: minAngle ?? this.minAngle,
    );
  }

  Size measure(DynamicText text, {num maxWidth = double.infinity}) {
    if (text.isEmpty) {
      return Size.zero;
    }
    if (text.isString) {
      var painter = textStyle.toPainter(text.text as String, maxLines: maxLines);
      painter.layout(maxWidth: maxWidth.toDouble());
      return painter.size;
    }
    if (text.isTextSpan) {
      var painter = TextPainter(
        text: text.text as TextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        textScaleFactor: 1,
        maxLines: maxLines,
        ellipsis: ellipsis,
      );
      painter.layout(maxWidth: maxWidth.toDouble());
      return painter.size;
    }
    ui.Paragraph p = text.text as ui.Paragraph;
    ui.ParagraphConstraints constraints = ui.ParagraphConstraints(width: maxWidth.toDouble());
    p.layout(constraints);
    return Size(p.width, p.height);
  }

  //TODO 待实现
  LabelStyle convert(Set<NodeState>? set) {
    if (set == null || set.isEmpty) {
      return this;
    }
    return this;
  }

  @override
  void drawArc(Canvas2 canvas, Paint paint, Arc arc, [bool useCircleRect = false]) {}

  @override
  void drawArc2(Canvas2 canvas, ui.Paint paint, num radius, num startAngle, num sweepAngle,
      [ui.Offset center = Offset.zero]) {}

  @override
  void drawCircle(Canvas2 canvas, ui.Paint paint, ui.Offset center, num radius) {}

  @override
  void drawDashPath(Canvas2 canvas, ui.Paint paint, ui.Path path, [ui.Rect? bound]) {}

  @override
  void drawLine(Canvas2 canvas, ui.Paint paint, ui.Offset start, ui.Offset end, [ui.Rect? bounds]) {}

  @override
  void drawPath(Canvas2 canvas, ui.Paint paint, ui.Path path, [ui.Rect? bound]) {}

  @override
  void drawPolygon(Canvas2 canvas, ui.Paint paint, List<ui.Offset> points, [bool closed = true, ui.Rect? bound]) {}

  @override
  void drawRRect(Canvas2 canvas, ui.Paint paint, ui.RRect rect) {}

  @override
  void drawRect(Canvas2 canvas, ui.Paint paint, ui.Rect rect, [Corner? corner]) {}

  @override
  CStyle lerpTo(covariant CStyle? end, double t) {
    throw UnimplementedError();
  }

  Widget toWidget(DynamicText text) {
    if (!show) {
      return const SizedBox(width: 0, height: 0);
    }
    Widget tw = text.toWidget(textStyle, maxLines: maxLines);
    if (decoration != null) {
      tw = DecoratedBox(decoration: decoration!, child: tw);
    }

    if (rotate != 0) {
      tw = RotationTransition(
        turns: AlwaysStoppedAnimation(rotate),
        child: tw,
      );
    }
    return tw;
  }
}

///文本超出绘制范围后的处理方式
enum TextTransborder {
  ignore,
  clip,
  scale,
}

enum OverFlow {
  notDraw,
  ignore,
  clip,
  scale,
}
