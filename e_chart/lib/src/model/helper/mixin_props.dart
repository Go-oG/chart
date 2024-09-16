import 'package:e_chart/e_chart.dart';

import '../error.dart';

///拓展字段属性
mixin ExtProps {
  late Map<String, dynamic> _extendProps = {};

  void putAttr(String key, dynamic data) {
    _extendProps[key] = data;
  }

  void putAllAttr(Map<String, dynamic> map) {
    map.forEach((key, value) {
      _extendProps[key] = value;
    });
  }

  void removeAttr(String key) {
    _extendProps.remove(key);
  }

  void clearAttr() {
    _extendProps = {};
  }

  T? getAttr2<T>(String key) {
    return _extendProps[key];
  }

  T getAttr<T>(String key, [T? defVal]) {
    T? value = getAttr2(key);
    if (value != null) {
      return value;
    }
    if (defVal != null) {
      putAttr(key, defVal);
      return defVal;
    }
    throw ChartError("not value");
  }

  Map<String, dynamic> getAllAttr() {
    return Map.from(_extendProps);
  }
}
