import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as md;

import 'package:vector_math/vector_math_64.dart';

class Text2 extends CShape with Drawable {
  static final Text2 empty = Text2(text: null);

  DynamicText? text;
  LabelStyle style = const LabelStyle();
  TextAlign textAlign = TextAlign.center;

  ///绘制方向
  Direction direction = Direction.horizontal;

  ///对齐点，该点描述为让文本的哪个位置和该点对齐
  Offset alignPoint = Offset.zero;
  Alignment pointAlign = Alignment.center;
  Alignment rotateAlign = Alignment.center;

  double maxWidth = double.infinity;
  double maxHeight = double.infinity;
  double rotate = 0;

  int? maxLines;
  int? maxEms;

  bool single = false;

  String? ellipsis;
  double textScaleFactor = 1.0;
  TextOverflow overflow = TextOverflow.clip;

  ///背景
  BoxDecoration? decoration;

  Text2({
    this.text,
    this.style = const LabelStyle(),
    this.textAlign = TextAlign.center,
    this.direction = Direction.horizontal,
    this.alignPoint = Offset.zero,
    this.pointAlign = Alignment.center,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.rotate = 0,
    this.maxLines,
    this.single = false,
    this.ellipsis,
    this.textScaleFactor = 1.0,
    this.overflow = TextOverflow.clip,
    this.decoration,
  });

  Text2.of(
    this.text,
    this.style,
    this.alignPoint, {
    this.textAlign = TextAlign.center,
    this.direction = Direction.horizontal,
    this.pointAlign = Alignment.center,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.rotate = 0,
    this.maxLines,
    this.single = false,
    this.ellipsis,
    this.textScaleFactor = 1.0,
    this.overflow = TextOverflow.clip,
    this.decoration,
  });

  ///========用于绘制的数据=========

  TextPainter? _painter;

  BoxPainter? _boxPainter;

  ImageConfiguration? _boxConfig;
  Rect _textRect = Rect.zero;

  Rect _boxRect = Rect.zero;

  ///当更改了一个属性后必须调用该方法重新计算
  @override
  void markDirty() {
    _painter = null;
    _boxPainter = decoration?.createBoxPainter(() {
      //TODO 应该重绘

    });
    _boxConfig = null;
    _boxRect = Rect.zero;
    var text = _adjustText(this.text);
    if (text == null || text.isEmpty) {
      return;
    }

    TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style.textStyle),
      textAlign: textAlign,
      maxLines: _adjustMaxLines(),
      ellipsis: ellipsis,
      textScaler: TextScaler.linear(textScaleFactor),
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    );
    painter.layout(minWidth: 0, maxWidth: _adjustMaxWidth());
    _painter = painter;
    var offset = _computeTopLeftOffset(painter);
    _textRect = Rect.fromLTWH(offset.dx, offset.dy, painter.width, painter.height);

    var boxPainter = _boxPainter;
    if (boxPainter != null) {
      if (_textRect.height > maxHeight) {
        _boxRect = Rect.fromLTWH(_textRect.left, _textRect.top, _textRect.width, maxHeight);
      } else {
        _boxRect = _textRect;
      }
      _boxConfig = ImageConfiguration(size: _boxRect.size);
    }
  }

  void update2({LabelStyle? style, Offset? alignPoint, Alignment? pointAlign}) {
    bool change = style != null || alignPoint != null || pointAlign != null;
    if (style != null) {
      this.style = style;
    }
    if (alignPoint != null) {
      this.alignPoint = alignPoint;
    }
    if (pointAlign != null) {
      this.pointAlign = pointAlign;
    }

    if (change) {
      markDirty();
    }
  }

  @override
  void render(Canvas2 canvas, Paint paint, CStyle style) {
    draw(canvas, paint);
  }

  @override
  void draw(Canvas2 canvas, Paint paint) {
    var painter = _painter;
    var boxRect = _boxRect;
    var boxPainter = _boxPainter;
    var boxConfig = _boxConfig;
    if (painter == null || boxRect.isEmpty) {
      return;
    }
    var angle = rotate;

    canvas.save();
    var cc = _computeRotateOffset(boxRect);
    canvas.translate(cc.dx, cc.dy);
    canvas.rotate(radians(angle));
    canvas.translate(-cc.dx, -cc.dy);
    canvas.clipRect(boxRect);

    if (boxPainter != null && boxConfig != null) {
      boxPainter.paint(canvas.canvas, boxRect.topLeft, boxConfig);
    }
    painter.paint(canvas.canvas, boxRect.topLeft);
    canvas.restore();
  }

  String? _adjustText(DynamicText? dynamicText) {
    var text = dynamicText?.toString();
    if (text == null || text.isEmpty) {
      return null;
    }
    var maxEms = this.maxEms;
    if (maxEms != null && maxEms > 0 && text.characters.length > maxEms) {
      text = text.characters.take(maxEms).toString();
    }
    if (!single || direction == Direction.horizontal) {
      return text;
    }
    List<String> sl = [];
    for (var item in text.characters) {
      if (item == "\n" || item == "\r" || item == "\r\n") {
        continue;
      }
      sl.add(item);
    }
    return sl.join("\n");
  }

  int? _adjustMaxLines() {
    if (!single) {
      return maxLines;
    }
    if (direction == Direction.horizontal) {
      return 1;
    }
    return null;
  }

  double _adjustMaxWidth() {
    if (!single) {
      return maxWidth;
    }
    if (direction == Direction.horizontal) {
      return maxWidth;
    }
    return (style.textStyle.fontSize ?? 15) * 1.3 * textScaleFactor;
  }

  Offset _computeTopLeftOffset(TextPainter painter) {
    double width = painter.width;
    double height = painter.height;
    var px = (pointAlign.x + 1) * 0.5 * width;
    var py = (pointAlign.y + 1) * 0.5 * height;
    double x = alignPoint.dx - px;
    double y = alignPoint.dy - py;
    return Offset(x, y);
  }

  ///计算旋转中心点
  Offset _computeRotateOffset(Rect boxRect) {
    var angle = rotate % 360;
    if (angle == 0) {
      return Offset.zero;
    }
    return rotateAlign.withinRect(boxRect);
  }

  @override
  Path buildPath() {
    return Path();
  }

  @override
  void fill(Attrs attr) {}

  @override
  bool get isClosed => false;
}
