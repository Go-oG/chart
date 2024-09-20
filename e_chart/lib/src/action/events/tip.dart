import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///ToolTip
class ToolTipEvent extends ChartEvent {
  final Rect position;
  final EventOrder order;

  ToolTipEvent(this.position, this.order);

  @override
  EventType get eventType => EventType.tooltip;
}
