import '../weighted_event.dart';

class Triangle {
  WeightEvent? last;
  WeightEvent? curr;
  WeightEvent? next;

  void _updateWeight() {
    var last = this.last;
    var curr = this.curr;
    var next = this.next;

    if (last == null || curr == null || next == null) {
      return;
    }
    num dx1 = curr.getOrder() - last.getOrder();
    num dx2 = last.getOrder() - next.getOrder();
    num dx3 = next.getOrder() - curr.getOrder();
    double y1 = next.getValue();
    double y2 = curr.getValue();
    double y3 = last.getValue();
    double s = 0.5 * (y1 * dx1 + y2 * dx2 + y3 * dx3).abs();
    curr.setWeight(s);
  }

  void calc(WeightEvent? e) {
    last = curr;
    curr = next;
    next = e;
    _updateWeight();
  }

  void calc2(WeightEvent? last, WeightEvent? curr, WeightEvent? next) {
    this.last = last;
    this.curr = curr;
    this.next = next;
    _updateWeight();
  }
}
