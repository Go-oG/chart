import 'package:e_chart/e_chart.dart';

/// 支持年月日 周
class TimeScale extends BaseScale<DateTime> {
  TimeType splitType;

  TimeScale(this.splitType, super.domain, super.range) {
    if (domain.length < 2) {
      throw ChartError('TimeScale Domain必须大于等于2');
    }
  }

  @override
  double convert(DateTime domainValue) {
    int diff2 = _computeTickCount(domain.first, domainValue, splitType);
    if (diff2.abs() == 0) {
      return this.range[0];
    }
    return convertRatio(normalize(domainValue));
  }

  @override
  double convertRatio(double domainRatio) {
    return this.range.first + (this.range.last - this.range.first) * domainRatio;
  }

  @override
  double normalize(DateTime domainValue) {
    int diff = _computeTickCount(domain.first, domain.last, splitType);
    int diff2 = _computeTickCount(domain.first, domainValue, splitType);
    return diff2 / diff;
  }

  @override
  DateTime invert(double rangeValue) {
    num diff2 = this.range.last - this.range.first;
    double p = (rangeValue - this.range.first) / diff2;
    return invertRatio(p);
  }

  @override
  DateTime invertRatio(double rangeRatio) {
    int diff = _computeTickCount(domain.first, domain.last, splitType);
    int v = (rangeRatio * diff).ceil();
    return _convertValue(domain.first, v, splitType);
  }

  @override
  int get tickCount => _computeTickCount(domain.first, domain.last, splitType) + 1;

  @override
  bool get isTime => true;

  @override
  List<DateTime> get labels {
    List<DateTime> tl = [];
    int count = tickCount;
    for (int i = 0; i <= count; i++) {
      tl.add(_convertValue(domain.first, i, splitType));
    }
    return tl;
  }

  @override
  List<DateTime> getRangeLabel(int startIndex, int endIndex) {
    List<DateTime> tl = [];
    int count = tickCount;
    if (startIndex < 0) {
      startIndex = 0;
    }
    if (endIndex > count) {
      endIndex = count;
    }
    for (int i = startIndex; i <= endIndex; i++) {
      tl.add(_convertValue(domain.first, i, splitType));
    }
    return tl;
  }

  static int _computeTickCount(DateTime s, DateTime e, TimeType splitType) {
    if (splitType == TimeType.week) {
      int day = s.diffDay(e);
      if (day % 7 == 0) {
        return day;
      }
      return day ~/ 7 + 1;
    }

    if (splitType == TimeType.year) {
      return s.diffYear(e);
    }
    if (splitType == TimeType.month) {
      return s.diffMonth(e);
    }
    if (splitType == TimeType.day) {
      return s.diffDay(e);
    }
    if (splitType == TimeType.hour) {
      return s.diffHour(e);
    }
    if (splitType == TimeType.minute) {
      return s.diffMinute(e);
    }
    return s.diffSec(e);
  }

  static DateTime _convertValue(DateTime start, int v, TimeType splitType) {
    if (splitType == TimeType.week) {
      return start.add(Duration(days: v * 7));
    }
    if (splitType == TimeType.year) {
      return DateTime(start.year + v, start.month, start.day);
    }
    if (splitType == TimeType.month) {
      int year = start.year;
      year += v ~/ 12;
      int m = v % 12;
      return DateTime(year, m, 1);
    }
    if (splitType == TimeType.day) {
      return start.add(Duration(days: v));
    }
    if (splitType == TimeType.hour) {
      return start.add(Duration(hours: v));
    }
    if (splitType == TimeType.minute) {
      return start.add(Duration(minutes: v));
    }
    return start.add(Duration(seconds: v));
  }

  @override
  TimeScale copyWithRange(List<double> range) {
    return TimeScale(splitType, domain, range);
  }

  @override
  bool get hasZero => false;

  @override
  int getBandIndex(DateTime domainValue) {
    return _computeTickCount(domain.first, domainValue, splitType);
  }
}
