import '../event.dart';

class PlainEvent implements Event {
  final int _time;

  final double _value;

  const PlainEvent(this._time, this._value);

  @override
  int getTime() {
    return _time;
  }

  @override
  double getValue() {
    return _value;
  }

  @override
  int get hashCode {
    final int prime = 31;
    int result = 1;
    result = (prime * result + (_time ^ (_time >>> 32))).toInt();
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PlainEvent && other._time == _time;
  }
}
