import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';

class LogScale extends LinearScale {
  final double base;

  LogScale(
    super.domain,
    super.range, {
    this.base = 10,
    required super.step,
  }) {
    if (base == 0) {
      throw ChartError('Base 必须不为0');
    }
  }

  @override
  LogScale copyWithRange(List<double> range) {
    return LogScale(domain, range, base: base, step: step);
  }

  @override
  double invert(double rangeValue) {
    num lg = super.invert(rangeValue);
    return m.pow(base, lg).toDouble();
  }

  @override
  double convert(num domainValue) {
    return super.convert(_convert(domainValue));
  }

  double _convert(num n) {
    return m.log(n) / m.log(base);
  }
}
