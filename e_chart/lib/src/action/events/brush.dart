import 'package:e_chart/e_chart.dart';

class BrushEvent extends ChartEvent {
  final EventOrder order;
  final String coordId;
  final Brush brush;
  List<BrushArea> areas = [];

  BrushEvent(this.order, this.coordId, this.brush, this.areas);

  @override
  EventType get eventType => EventType.brush;
}

