
import '../event.dart';
import '../event_dispatcher.dart';

class ChartDisposeEvent extends ChartEvent {
  static const single = ChartDisposeEvent();

  const ChartDisposeEvent();

  @override
  EventType get eventType => EventType.chartDispose;
}
