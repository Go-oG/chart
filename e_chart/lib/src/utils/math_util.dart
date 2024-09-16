import 'dart:math' as math;
import 'dart:math';
import 'package:e_chart/src/model/error.dart';
import 'package:flutter/widgets.dart';

Random _random = Random();

T max2<T extends num>(Iterable<T> list) {
  return maxBy<T>(list, (p0) => p0);
}

T maxBy<T>(Iterable<T> list, num Function(T) convert) {
  if (list.isEmpty) {
    throw FlutterError('列表为空');
  }
  num v = convert.call(list.first);
  T result = list.first;
  for (var v2 in list) {
    var tv = convert.call(v2);
    if (tv.compareTo(v) > 0) {
      v = tv;
      result = v2;
    }
  }
  return result!;
}

num maxBy2<T>(Iterable<T> list, num Function(T) convert) {
  if (list.isEmpty) {
    throw FlutterError('列表为空');
  }
  num v = convert.call(list.first);
  for (var v2 in list) {
    var tv = convert.call(v2);
    if (tv.compareTo(v) > 0) {
      v = tv;
    }
  }
  return v;
}

T min2<T extends num>(Iterable<T> list) {
  return minBy<T>(list, (p0) => p0);
}

T minBy<T>(Iterable<T> list, num Function(T) convert) {
  if (list.isEmpty) {
    throw ChartError('List Is Empty');
  }
  num v = convert.call(list.first);
  T result = list.first;
  for (var v2 in list) {
    var tv = convert.call(v2);
    if (tv.compareTo(v) < 0) {
      v = tv;
      result = v2;
    }
  }
  return result;
}

num minBy2<T>(Iterable<T> list, num Function(T) convert) {
  if (list.isEmpty) {
    throw ChartError('List Is Empty');
  }
  num v = convert.call(list.first);
  for (var v2 in list) {
    var tv = convert.call(v2);
    if (tv.compareTo(v) < 0) {
      v = tv;
    }
  }
  return v;
}

List<num> extremes<T>(Iterable<T> list, num Function(T) call) {
  if (list.isEmpty) {
    return [0, 0];
  }
  T first = list.first;
  num minValue = call(first);
  num maxValue = call(first);

  for (var ele in list) {
    num v = call(ele);
    minValue = math.min(minValue, v);
    maxValue = math.max(maxValue, v);
  }
  return [minValue, maxValue];
}

List<T> extremesBy<T>(Iterable<T?> list, int Function(T, T) call) {
  if (list.isEmpty) {
    return [];
  }
  if (list.length == 1) {
    var first = list.first;
    if (first == null) {
      return [];
    }
    return [first, first];
  }

  T? maxValue;
  T? minValue;
  for (var ele in list) {
    if (ele == null) {
      continue;
    }
    if (maxValue == null) {
      maxValue = ele;
    } else {
      if (call.call(maxValue, ele) < 0) {
        maxValue = ele;
      }
    }
    if (minValue == null) {
      minValue = ele;
    } else {
      if (call.call(minValue, ele) > 0) {
        minValue = ele;
      }
    }
  }

  List<T> resultList = [];
  if (minValue != null) {
    resultList.add(minValue);
  }
  if (maxValue != null) {
    resultList.add(maxValue);
  }

  return resultList;
}

double sum(Iterable<num> list) {
  return sumBy<num>(list, (p0) => p0);
}

double sumBy<T>(Iterable<T> list, num Function(T) call) {
  ///下面这样写是为了避免浮点数精度丢失
  ///Kahan's summation Formula 算法
  double sumV = 0.0;
  var c = 0.0;
  for (var value in list) {
    var y = call.call(value) - c;
    var t = sumV + y;
    c = (t - sumV) - y;
    sumV = t;
  }
  return sumV;
}

num ave(Iterable<num> list) {
  return aveBy<num>(list, (p0) => p0);
}

num aveBy<T>(Iterable<T> list, num Function(T) call) {
  if (list.isEmpty) {
    return 0;
  }
  return sumBy<T>(list, call) / list.length;
}

num reduce<T>(Iterable<T> list, num Function(num, T) call, [num initValue = 0]) {
  num sum = initValue;
  for (var c in list) {
    sum = call(sum, c);
  }
  return sum;
}

///中位数
num medium(Iterable<num> list) {
  return mediumBy<num>(list, (p0) => p0);
}

num mediumBy<T>(Iterable<T> list, num Function(T) call) {
  List<num> nl = [];
  for (var element in list) {
    nl.add(call(element));
  }
  nl.sort();
  int index = nl.length ~/ 2;
  if (nl.length % 2 == 0) {
    return (nl[index] + nl[index + 1]) / 2;
  } else {
    return nl[index];
  }
}

List<T> mediumBy2<T>(Iterable<T> list, int Function(T, T) call) {
  List<T> tmpList = List.from(list);
  if (tmpList.length <= 1) {
    return tmpList;
  }
  tmpList.sort((a, b) {
    return call.call(a, b);
  });
  int index = tmpList.length ~/ 2;
  if (tmpList.length % 2 == 0) {
    return [tmpList[index], tmpList[index + 1]];
  } else {
    return [tmpList[index]];
  }
}

num log10(num v) {
  return math.log(v) / math.ln10;
}

num hypot(List<num> list) {
  double a = 0;
  for (var c in list) {
    a += c * c;
  }
  return math.sqrt(a);
}

///求三角形面积
num triangleArea(Offset p1, Offset p2, Offset p3) {
  return 0.5 * ((p1.dx * p2.dy - p2.dx * p1.dy) + (p2.dx * p3.dy - p3.dx * p2.dy) + (p3.dx * p1.dy - p1.dx * p3.dy));
}

num clamp(num lower, num upper) {
  var p = _random.nextDouble();
  var diff = (upper - lower);
  return lower + diff * p;
}

List<int> range(int start, int end, [int step = 1]) {
  int index = -1;
  int length = max(((end - start) / step).ceil(), 0);
  List<int> rl = List.filled(length, 0);
  while ((length--) != 0) {
    rl[++index] = start;
    start += step;
  }
  return rl;
}

///有值的在没值的前面
int compareValue(dynamic a, dynamic b) {
  if (a == null) {
    if (b == null) {
      return 0;
    }
    return 1;
  }
  if (b == null) {
    return -1;
  }

  if (a is num && b is num) {
    return a.compareTo(b);
  }

  if (a is Comparable && b is Comparable) {
    return Comparable.compare(a, b);
  }

  throw UnSupportError("only support num or comparable");
}

dynamic medianValue(dynamic a, dynamic b) {
  if (a == null) {
    if (b == null) {
      return null;
    }
    return b;
  }

  if (b == null) {
    return a;
  }

  if (a is num && b is num) {
    return (a + b) / 2;
  }
  return a;
}

//保留n位小数
num roundFun(num value, int n) {
  return (value * pow(10, n)).round() / pow(10, n);
}

num random() {
  return _random.nextDouble();
}

int randomInt(int min, int max) {
  var r = _random.nextDouble();
  return (r * (max - min)).floor() + min;
}
