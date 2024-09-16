import '../event.dart';
import '../event_dispatcher.dart';

class RenderedEvent extends ChartEvent {
  static const RenderedEvent rendered = RenderedEvent();

  const RenderedEvent();

  @override
  EventType get eventType => EventType.rendered;
}
