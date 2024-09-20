import '../ds_algorithm.dart';
import 'plain_event.dart';

class WeightEvent implements OrderData {
  late OrderData _event;
  double _weight = 0;

  WeightEvent.of(int time, double value) {
    _event = PlainEvent(time, value);
  }

  WeightEvent(this._event);

  OrderData getEvent() {
    return _event;
  }

  @override
  num getOrder() {
    return _event.getOrder();
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
    return Object.hash(_event.getOrder(), _event.getValue());
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! WeightEvent) {
      return false;
    }
    if (_event.getOrder() != other._event.getOrder()) {
      return false;
    }
    if (_event.getValue() != other._event.getValue()) {
      return false;
    }

    return true;
  }
}
