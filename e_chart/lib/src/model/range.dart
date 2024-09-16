class Range<T> {
  final T begin;
  final T end;

  const Range(this.begin, this.end);

  @override
  String toString() {
    return "[${begin.toString()},${end.toString()}]";
  }
}

class RangeD extends Range<double> {
  RangeD(super.begin, super.end);

  RangeD.fix(double v) : this(v, v);

  RangeD.infinitely() : this(double.minPositive, double.maxFinite);

  RangeD.upInfinitely(double low) : this(low, double.infinity);

  RangeD.lowInfinitely(double up) : this(double.minPositive, up);

  double clamp(double value) {
    if (value >= begin && value <= end) {
      return value;
    }
    return value.clamp(begin, end);
  }
}
