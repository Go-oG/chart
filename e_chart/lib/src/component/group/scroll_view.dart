import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ScrollLayout extends ChartViewGroup {
  double _dy = 0;

  ScrollLayout(super.context);

  @override
  Future<void>  onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) async{
    if (children.length > 1) {
      throw ChartError("只能有一个View");
    }
    var parentHeight = heightSpec.size;

    var child = children.first;
    child.measure(widthSpec, heightSpec);
    final double cw = child.width;
    final double ch = child.height;
    Size size;
    if (parentHeight.isInfinite || parentHeight.isNaN) {
      size = Size(cw, ch);
    } else if (ch > parentHeight) {
      size = Size(cw, parentHeight);
    } else {
      size = Size(cw, ch);
    }
    setMeasuredDimension(size.width, size.height);
    return ;
  }

  bool drawSelf(Canvas2 canvas, ChartViewGroup parent) {
    canvas.save();
    canvas.translate(left, top + _dy);
    canvas.clipRect(Rect.fromLTWH(0, _dy.abs(), width, height));
    draw(canvas);
    canvas.restore();
    return false;
  }


  @override
  void onDragMove(Offset local, Offset global, Offset diff) {
    var sub = children.first.height - height;
    if (sub <= 0) {
      return;
    }
    _dy += diff.dy;

    if (_dy.abs() >= sub) {
      _dy = -sub;
    }
    if (_dy >= 0) {
      _dy = 0;
    }
    repaint();
  }
}
