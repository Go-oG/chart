import 'dart:ui';

import 'package:e_chart/e_chart.dart';

mixin Drawable {
  double width = 0;
  double height = 0;

  void draw(Canvas2 canvas, Paint paint) {}

  void dispose() {}
}
