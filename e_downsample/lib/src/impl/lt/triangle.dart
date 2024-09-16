import '../weighted_event.dart';

class Triangle {
  WeightedEvent? last;
  WeightedEvent? curr;
  WeightedEvent? next;

  void _updateWeight() {
    var last = this.last;
    var curr = this.curr;
    var next = this.next;

    if (last == null || curr == null || next == null) {
      return;
    }
    int dx1 = curr.getTime() - last.getTime();
    int dx2 = last.getTime() - next.getTime();
    int dx3 = next.getTime() - curr.getTime();
    double y1 = next.getValue();
    double y2 = curr.getValue();
    double y3 = last.getValue();
    double s = 0.5 * (y1 * dx1 + y2 * dx2 + y3 * dx3).abs();
    curr.setWeight(s);
  }

  void calc(WeightedEvent? e) {
    last = curr;
    curr = next;
    next = e;
    _updateWeight();
  }

  void calc2(WeightedEvent? last, WeightedEvent? curr, WeightedEvent? next) {
    this.last = last;
    this.curr = curr;
    this.next = next;
    _updateWeight();
  }
}
