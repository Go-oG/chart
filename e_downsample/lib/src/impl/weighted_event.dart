import 'package:e_downsample/src/impl/plain_event.dart';

import '../event.dart';

class WeightedEvent implements Event {
  late Event _event;
  late double _weight;

  WeightedEvent.of(int time, double value) {
    _event = PlainEvent(time, value);
  }

  WeightedEvent(this._event);

  Event getEvent() {
    return _event;
  }

  @override
  int getTime() {
    return _event.getTime();
  }

  @override
  double getValue() {
    return _event.getValue();
  }

  double getWeight() {
    return _weight;
  }

  void setWeight(double weight) {
    _weight = weight;
  }

  @override
  int get hashCode {
    return Object.hash(_event.getTime(), _event.getValue());
  }

  @override
  bool operator ==(Object obj) {
    if (identical(obj, this)) {
      return true;
    }

    if (obj.runtimeType != runtimeType) {
      return false;
    }

    WeightedEvent other = obj as WeightedEvent;
    if (other._event == null || _event == null) {
      return false;
    }
    if (_event.getTime() != other._event.getTime()) {
      return false;
    }
    if (_event.getValue() != other._event.getValue()) {
      return false;
    }

    return true;
  }
}
