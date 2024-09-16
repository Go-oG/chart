import 'package:e_chart/e_chart.dart';

///将给定的domain映射到range
abstract class BaseScale<D> extends Disposable {
  ///表示域的范围(定义域)
  late List<D> domain;

  ///映射域的值(值域)
  late List<double> range;

  BaseScale(List<D> domain, List<double> range) {
    if (range.length < 2) {
      throw ChartError('Range 必须大于等于2');
    }
    this.domain = List.from(domain);
    this.range = List.from(range);
  }

  ///将给定的定义域值映射到Range
  double convert(D domainValue);

  ///将给定定义域百分比映射到Range
  double convertRatio(double domainRatio);

  ///将给定的定义域值进行归一化
  double normalize(D domainValue);

  D invert(double rangeValue);

  D invertRatio(double rangeRatio);

  ///返回Tick的个数
  int get tickCount;

  List<D> get labels;

  ///Tick之间的距离间距
  ///该间距是一个大间距,非每个小tick 之间的间距
  double get bandSize {
    double v = (range[1] - range[0]).abs();
    int c = tickCount - 1;
    if (c < 1) {
      return v.toDouble();
    }
    return v / c;
  }

  ///每个MainTick 之间的距离占整个轴长度的比例
  double get bandRatio {
    if (isCategory) {
      return 1 / domain.length;
    }
    return 1 / tickCount;
  }

  bool get isCategory => false;

  bool get isTime => false;

  bool get isLog => false;

  bool get isNum {
    return !isCategory && !isTime;
  }

  bool get hasZero;

  double get rangeValue {
    return range.last - range.first;
  }

  List<D> getRangeLabel(int startIndex, int endIndex);

  BaseScale<D> copyWithRange(List<double> range);

  void changeDomain(List<D> newDomain) {
    this.domain = newDomain;
  }

  void changeRange(List<double> newRange) {
    this.range = newRange;
  }

  @override
  void dispose() {
    super.dispose();
    domain.clear();
    range.clear();
  }

  @override
  String toString() {
    return "domain:$domain range:$range";
  }
}
