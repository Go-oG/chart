import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class DelaunayNode extends DataNode {
  List<Offset> points;

  DelaunayNode(
    Geom geom,
    this.points, {
    super.index,
    super.priority,
    super.value,
  }) : super(geom, RawData());

  bool get isEmpty => index < 0 || points.isEmpty;
}
