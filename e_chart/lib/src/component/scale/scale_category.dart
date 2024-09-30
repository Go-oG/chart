import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';

class CategoryScale extends BaseScale<String> {
  bool categoryCenter;
  List<double> flex;

  @protected
  List<List<double>> bandList = [];

  CategoryScale(
    super.domain,
    super.range,
    this.categoryCenter, {
    this.flex = const [],
  }) {
    if (domain.isEmpty) {
      throw ChartError('Domain至少应该有一个');
    }
    _updateBand();
  }

  @override
  String invert(double rangeValue) {
    double diff = this.range.last - this.range.first;
    double interval = diff / domain.length;
    int diff2 = (rangeValue - this.range.first) ~/ interval;
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
    num diff = this.range.last - this.range.first;
    int c = domain.length;
    if (!categoryCenter) {
      c -= 1;
    }
    if (c <= 0) {
      c = 1;
    }
    num interval = diff / c;
    return this.range.first + index * interval;
  }

  @override
  double convertRatio(double domainRatio) {
    double diff = this.range.last - this.range.first;
    return this.range.first + domainRatio * diff;
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
  double getBandSize(int index) {
    if (index < 0 || index >= bandList.length) {
      throw ArgumentError();
    }
    return bandList[index][1] - bandList[index][0];
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

  @override
  void setDomain(List<String> newDomain) {
    super.setDomain(newDomain);
    _updateBand();
  }

  @override
  void setRange(List<double> newRange) {
    super.setRange(newRange);
    _updateBand();
  }

  void setFlex(List<double> flex) {
    this.flex = flex;
    _updateBand();
  }

  void _updateBand() {
    List<double> list = [...flex];
    if (list.isEmpty) {
      each(domain, (v, i) {
        list.add(1);
      });
    } else {
      if (list.length > domain.length) {
        list.removeRange(domain.length, list.length);
      } else {
        int remainCount = domain.length - list.length;
        for (int i = 0; i < remainCount; i++) {
          list.add(1);
        }
      }
    }
    List<List<double>> cellList = [];
    var sumValue = sum(list);
    double offset = 0;
    var star = this.range.first;
    var all = this.range.last - this.range.first;
    for (var item in list) {
      var p = item / sumValue;
      cellList.add([star + offset * all, star + (offset + p) * all]);
      offset += p;
    }
    bandList = cellList;
  }

  @override
  int getBandIndex(String domainValue) {
    return domain.findIndex(domainValue);
  }
}
