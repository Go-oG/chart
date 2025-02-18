import 'package:e_chart/e_chart.dart';

///整个图表通用的数据模型
class RawData {
  static final RawData empty = RawData();
  late final String id;
  final String? groupId;

  final Map<String, dynamic> _valueMap = {};

  RawData({
    String? id,
    this.groupId,
  }) {
    this.id = isEmpty(id) ? randomId() : id!;
  }

  RawData.fromValue(
    dynamic value, {
    String? id,
    this.groupId,
  }) {
    this.id = isEmpty(id) ? randomId() : id!;
    put("value", value);
  }

  RawData.fromMap(
    Map<String, dynamic>? data, {
    String? id,
    this.groupId,
  }) {
    this.id = isEmpty(id) ? randomId() : id!;
    putAll(data);
  }

  RawData put(String key, dynamic data) {
    _checkFreeze();
    _valueMap[key] = data;
    return this;
  }

  RawData putAll(Map<String, dynamic>? map) {
    if (map != null) {
      _checkFreeze();
      map.forEach((key, value) {
        _valueMap[key] = value;
      });
    }
    return this;
  }

  dynamic remove(String key) {
    _checkFreeze();
    return _valueMap.remove(key);
  }

  List<dynamic> removeAt(Iterable<String> keys) {
    _checkFreeze();
    List<dynamic> list = [];
    each(keys, (p0, p1) {
      list.add(_valueMap.remove(p0));
    });
    return list;
  }

  RawData clean() {
    _checkFreeze();
    _valueMap.clear();
    return this;
  }

  RawData removeNotInclude(Iterable<String> keys) {
    _checkFreeze();
    Set<String> set = (keys is Set<String>) ? keys : Set.from(keys);
    _valueMap.removeWhere((key, value) => !set.contains(key));
    return this;
  }

  T get<T>(String attr, [T? defVal]) {
    T? value = get2(attr);
    if (value != null) {
      return value as T;
    }
    if (defVal != null) {
      put(attr, defVal);
      return defVal as T;
    }
    throw ChartError("not value");
  }

  T? get2<T>(String attr) {
    return _valueMap[attr] as T?;
  }

  dynamic operator [](String name) {
    return _valueMap[name];
  }

  void operator []=(String name, dynamic value) {
    _checkFreeze();
    _valueMap[name] = value;
  }

  RawData copy([bool keepFreeze = false]) {
    var data = RawData.fromMap(_valueMap);
    if (keepFreeze && isFreeze) {
      data.freeze();
    }
    return data;
  }

  Map<String, dynamic> pick(Iterable<String> fields) {
    Map<String, dynamic> map = {};
    for (var key in fields) {
      map[key] = _valueMap[key];
    }
    return map;
  }

  Map<String, dynamic> getAll() {
    return _valueMap;
  }

  String generateKey(Iterable<String> groupBy) {
    if (groupBy.isEmpty) {
      return "";
    }
    var builder = StringBuffer();
    for (var group in groupBy) {
      var value = get2(group);
      builder.write(key(value));
    }
    return builder.toString();
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is RawData && other.id == id;
  }

  bool _isFreeze = false;

  bool get isFreeze => _isFreeze;

  ///该方法会冻结所有试图修改操作，直到解冻
  void freeze() {
    _isFreeze = true;
  }

  ///解除冻结
  void unfreeze() {
    _isFreeze = false;
  }

  void _checkFreeze() {
    if (isFreeze) {
      throw UnsupportedError("Current object is freeze");
    }
  }
}
