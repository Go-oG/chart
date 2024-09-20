import '../ds_algorithm.dart';

class PlainEvent implements OrderData {
  final num _time;
  final double _value;

  const PlainEvent(this._time, this._value);

  @override
  num getOrder() {
    return _time;
  }

  @override
  double getValue() {
    return _value;
  }

  @override
  int get hashCode {
    return Object.hash(_time, _value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    return other is PlainEvent && other._time == _time;
  }
}
