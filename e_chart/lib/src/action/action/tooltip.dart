import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ShowTipAction extends ChartAction {
  final num x;
  final num y;
  final List<Offset>? position;
  final int? geomIndex;
  final int? dataIndex;
  final DynamicText? name;

  ShowTipAction(
    this.x,
    this.y, {
    this.position,
    this.geomIndex,
    this.dataIndex,
    this.name,
    super.fromUser,
  });
}

class HideTipAction extends ChartAction {
  HideTipAction({super.fromUser});
}
