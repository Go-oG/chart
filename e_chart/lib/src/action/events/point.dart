import 'dart:ui';

import '../event.dart';
import '../event_dispatcher.dart';

class ClickEvent extends ChartEvent {
  final EventInfo event;
  Offset localOffset;
  Offset globalOffset;

  ClickEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }

  @override
  EventType get eventType => EventType.click;
}

class DClickEvent extends ChartEvent {
  final Offset localOffset;
  final Offset globalOffset;
  final EventInfo event;

  DClickEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }

  @override
  EventType get eventType => EventType.doubleClick;
}

class HoverStartEvent extends ChartEvent {
  final EventInfo event;
  Offset localOffset;
  Offset globalOffset;

  HoverStartEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }

  @override
  EventType get eventType => EventType.hoverStart;
}

class HoverUpdateEvent extends ChartEvent {
  Offset localOffset;
  Offset globalOffset;
  final EventInfo event;

  HoverUpdateEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }

  @override
  EventType get eventType => EventType.hoverUpdate;
}

class HoverEndEvent extends ChartEvent {
  final EventInfo event;
  Offset localOffset;
  Offset globalOffset;

  HoverEndEvent(this.event, this.localOffset, this.globalOffset);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }

  @override
  EventType get eventType => EventType.hoverEnd;
}

class LongPressUpdateEvent extends ChartEvent {
  final EventInfo event;
  Offset localOffset;
  Offset globalOffset;

  LongPressUpdateEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType:$event";
  }

  @override
  EventType get eventType => EventType.longPressUpdate;
}

class LongPressEndEvent extends ChartEvent {
  final EventInfo event;

  LongPressEndEvent(this.event);

  @override
  String toString() {
    return "$runtimeType:$event";
  }

  @override
  EventType get eventType => EventType.longPressEnd;
}

class LongPressStartEvent extends ChartEvent {
  final EventInfo event;

  LongPressStartEvent(this.event);

  @override
  String toString() {
    return "$runtimeType:$event";
  }

  @override
  EventType get eventType => EventType.longPressStart;
}

class DragStartEvent extends ChartEvent {
  @override
  EventType get eventType => EventType.dragStart;
}

class DragUpdateEvent extends ChartEvent {
  @override
  EventType get eventType => EventType.dragUpdate;
}

class DragEndEvent extends ChartEvent {
  @override
  EventType get eventType => EventType.dragEnd;
}
