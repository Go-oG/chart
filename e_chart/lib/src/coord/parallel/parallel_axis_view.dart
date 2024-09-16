import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ParallelAxisView extends LineAxisView<ParallelAxis, ParallelAxisAttrs, ParallelCoord> {
  final Direction direction;
  bool expand = true;

  ParallelAxisView(this.direction, super.context, super.axis, super.coord, {super.axisIndex});

  @override
  void onDrawSplitLine(Canvas2 canvas, Paint paint) {}

  @override
  void onDrawSplitArea(Canvas2 canvas, Paint paint) {}

  @override
  List<Drawable>? onUpdateSplitArea(ParallelAxisAttrs attrs, BaseScale<dynamic> scale) {
    return null;
  }

  @override
  List<Drawable>? onUpdateSplitLine(ParallelAxisAttrs attrs, BaseScale<dynamic> scale) {
    return null;
  }

  @override
  ParallelAxisAttrs onBuildDefaultAttrs() => ParallelAxisAttrs(
        Rect.zero,
        Offset.zero,
        Offset.zero,
        Size.zero,
        Size.zero,
        true,
      );

  @override
  BaseScale get axisScale => throw UnimplementedError();
}

class ParallelAxisAttrs extends LineAxisAttrs {
  Size textStartSize;
  Size textEndSize;
  bool expand;

  ParallelAxisAttrs(
    super.rect,
    super.start,
    super.end,
    this.textStartSize,
    this.textEndSize,
    this.expand, {
    super.scaleRatio,
    super.scrollX,
    super.scrollY,
    super.splitCount,
  });

  @override
  ParallelAxisAttrs copy() {
    return ParallelAxisAttrs(
      rect,
      start,
      end,
      textStartSize,
      textEndSize,
      expand,
      scaleRatio: scaleRatio,
      scrollX: scrollX,
      scrollY: scrollY,
      splitCount: splitCount,
    );
  }
}
