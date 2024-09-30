import 'package:e_chart/e_chart.dart';

class LinearScale extends BaseScale<num> {
  final double step;

  ///表示域的范围
  LinearScale(
    super.domain,
    super.range, {
    required this.step,
  }) {
    if (domain.length < 2) {
      throw ChartError('LinearScale Domain必须大于等于2');
    }
    if (domain.first == domain.last) {
      throw ChartError("两个数值不能相等");
    }
  }

  @override
  double convert(num domainValue) {
    return convertRatio(normalize(domainValue));
  }

  @override
  double convertRatio(double domainRatio) {
    num diff2 = this.range.last - this.range.first;
    return domainRatio * diff2 + this.range.first;
  }

  @override
  double normalize(num domainValue) {
    num diff = domain.last - domain.first;
    return (domainValue - domain.first) / diff;
  }

  @override
  double invert(double rangeValue) {
    num diff = domain.last - domain.first;
    num diff2 = this.range.last - this.range.first;
    if (diff2 == 0) {
      return domain.first.toDouble();
    }
    double p = (rangeValue - this.range.first) / diff2;
    return domain.first + p * diff;
  }

  @override
  double invertRatio(double rangeRatio) {
    return domain.first + rangeRatio * (domain.last - domain.first);
  }

  @override
  int get tickCount {
    num diff = domain[1] - domain[0];
    diff = diff.abs();
    num v2 = step.abs();
    return 1 + diff ~/ v2;
  }

  @override
  LinearScale copyWithRange(List<double> range) {
    return LinearScale(domain, range, step: step);
  }

  @override
  List<double> get labels {
    int count = tickCount;
    num interval = (domain[1] - domain[0]) / (count - 1);
    List<double> tl = [];
    for (int i = 0; i < count; i++) {
      tl.add((domain[0] + interval * i).toDouble());
    }
    return tl;
  }

  @override
  List<double> getRangeLabel(int startIndex, int endIndex) {
    int count = tickCount;
    if (startIndex < 0) {
      startIndex = 0;
    }
    if (endIndex > count) {
      endIndex = count;
    }

    double interval = (domain[1] - domain[0]) / (count - 1);
    List<double> tl = [];
    for (int i = startIndex; i < endIndex; i++) {
      tl.add(domain[0] + interval * i);
    }
    return tl;
  }

  @override
  bool get hasZero {
    return (domain[0] <= 0 && domain[1] >= 0) || (domain[0] >= 0 && domain[1] <= 0);
  }

  @override
  int getBandIndex(num domainValue) {
    return domainValue ~/ step;
  }


}
