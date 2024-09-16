import 'package:e_chart/e_chart.dart';

import '../../data/state.dart';
import '../event.dart';
import '../event_dispatcher.dart';

///数据发生改变后的事件
class DataStatusChangeEvent extends ChartEvent {
  final dynamic data;
  final Set<NodeState> states;

  const DataStatusChangeEvent(this.data,this.states);

  @override
  EventType get eventType => EventType.dataStatusChanged;
}
