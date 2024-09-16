import 'dart:ui';
import '../../index.dart';

class RadiusAxisAttrs extends LineAxisAttrs {
  Offset center;

  RadiusAxisAttrs(
    this.center,
    super.rect,
    super.start,
    super.end, {
    super.scaleRatio,
    super.scrollX,
    super.scrollY,
    super.splitCount,
  });

  @override
  RadiusAxisAttrs copy() {
    return RadiusAxisAttrs(
      center,
      rect,
      start,
      end,
      scaleRatio: scaleRatio,
      scrollX: scrollX,
      scrollY: scrollY,
      splitCount: splitCount,
    );
  }
}
