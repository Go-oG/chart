import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///标识坐标轴的Title
class AxisTitleDrawable with Drawable {
  AxisName? name;
  late Text2 label;

  AxisTitleDrawable(this.name) {
    label = Text2(
        text: name?.name ?? DynamicText.empty,
        style: LabelStyle.empty,
        alignPoint: Offset.zero,
        pointAlign: Alignment.center);
  }

  @override
  void dispose() {
    super.dispose();
    label.dispose();
    label = Text2();
    name = null;
  }

  @override
  void draw(Canvas2 canvas, Paint paint) {
    label.draw(canvas, paint);
  }
}
