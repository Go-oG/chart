import '../../model/error.dart';
import 'scale_base.dart';

class CategoryScale extends BaseScale<String> {
  bool categoryCenter;

  CategoryScale(super.domain, super.range, this.categoryCenter) {
    if (domain.isEmpty) {
      throw ChartError('Domain至少应该有一个');
    }
  }

  @override
  String invert(double rangeValue) {
    double diff = range.last - range.first;
    double interval = diff / domain.length;
    int diff2 = (rangeValue - range.first) ~/ interval;
    if (diff2 < 0) {
      diff2 = 0;
    }
    if (diff2 >= domain.length) {
      diff2 = domain.length - 1;
    }
    return domain[diff2];
  }

  @override
  String invertRatio(double rangeRatio) {
    var c = (rangeRatio * domain.length).floor();
    return domain[c];
  }

  @override
  double convert(String domainValue) {
    int index = domain.indexOf(domainValue);
    if (index == -1) {
      return double.nan;
    }
    num diff = range.last - range.first;
    int c = domain.length;
    if (!categoryCenter) {
      c -= 1;
    }
    if (c <= 0) {
      c = 1;
    }
    num interval = diff / c;
    return range.first + index * interval;
  }

  @override
  double convertRatio(double domainRatio) {
    double diff = range.last - range.first;
    return range.first + domainRatio * diff;
  }

  @override
  double normalize(String domainValue) {
    int index = domain.indexOf(domainValue);
    if (index == -1) {
      return double.nan;
    }
    return index / domain.length;
  }

  @override
  double get bandSize {
    var dis = (range[1] - range[0]).abs();
    int c = domain.length;
    if (!categoryCenter) {
      c -= 1;
    }
    return dis / c;
  }

  @override
  int get tickCount => categoryCenter ? domain.length + 1 : domain.length;

  @override
  bool get isCategory => true;

  @override
  List<String> get labels => domain;

  @override
  CategoryScale copyWithRange(List<double> range) {
    return CategoryScale(domain, range, categoryCenter);
  }

  @override
  List<String> getRangeLabel(int startIndex, int endIndex) {
    if (startIndex < 0) {
      startIndex = 0;
    }
    if (endIndex > domain.length) {
      endIndex = domain.length;
    }
    List<String> dl = [];
    for (int i = startIndex; i < endIndex; i++) {
      dl.add(domain[i]);
    }
    return dl;
  }

  @override
  bool get hasZero => false;
}
