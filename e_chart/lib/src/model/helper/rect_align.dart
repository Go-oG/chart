import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';

class RectAlign {
  static const center = RectAlign();
  static const centerLeft = RectAlign(align: Alignment.centerLeft, inside: false);
  static const centerRight = RectAlign(align: Alignment.centerRight, inside: false);

  final Alignment align;
  final bool inside;

  const RectAlign({this.align = Alignment.center, this.inside = true});

  void fill(Text2 textDraw, Rect rect, LabelStyle style, Direction direction) {
    double x = rect.center.dx + align.x * rect.width / 2;
    double y = rect.center.dy + align.y * rect.height / 2;
    if (!inside) {
      double lineWidth = (style.guideLine?.length ?? 0).toDouble();
      List<num> lineGap = (style.guideLine?.gap ?? [0, 0]);
      if (direction == Direction.vertical) {
        int dir = align.x > 0 ? 1 : -1;
        x += dir * (lineWidth + lineGap[0]);
      } else {
        int dir = align.y > 0 ? 1 : -1;
        y += dir * (lineWidth + lineGap[1]);
      }
    }
    Offset offset = Offset(x, y);
    Alignment pointAlign = toInnerAlign(align);
    if (!inside) {
      pointAlign = Alignment(-pointAlign.x, -pointAlign.y);
    }
    textDraw.style = style;

    textDraw.update2(style: style, alignPoint: offset, pointAlign: pointAlign);
  }

  void fill2(Text2 draw, Arc arc, LabelStyle style, Direction direction) {
    var angle = (arc.startAngle + arc.sweepAngle / 2) + align.x * arc.sweepAngle.abs();
    num diff = arc.outRadius - arc.innerRadius;
    var radius = (arc.innerRadius + diff / 2) + align.y * diff;
    draw.update2(alignPoint: circlePoint(radius, angle, arc.center), pointAlign: Alignment.center);
  }
}
