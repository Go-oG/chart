import 'package:e_chart/e_chart.dart';

class LegendScrollEvent extends ChartEvent {
  LegendScrollEvent();

  @override
  EventType get eventType => EventType.legendScroll;
}

///图例事件
class LegendEvent extends ChartEvent {
  final List<LegendItem> selectedList;
  final List<LegendItem> unselectedList;

  const LegendEvent(this.selectedList, this.unselectedList);

  @override
  EventType get eventType => EventType.legend;
}

