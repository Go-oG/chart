import 'dart:ui';

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
    _valueMap[key] = data;
    return this;
  }

  RawData putAll(Map<String, dynamic>? map) {
    if (map != null) {
      map.forEach((key, value) {
        _valueMap[key] = value;
      });
    }
    return this;
  }

  dynamic remove(String key) {
    return _valueMap.remove(key);
  }

  List<dynamic> removeAt(Iterable<String> keys) {
    List<dynamic> list = [];
    each(keys, (p0, p1) {
      list.add(_valueMap.remove(p0));
    });
    return list;
  }

  RawData clean() {
    _valueMap.clear();
    return this;
  }

  RawData removeNotInclude(Iterable<String> keys) {
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

  T getAttr<T>(Attr attr, [T? defVal]) {
    return get(attr.name, defVal);
  }

  T? getAttr2<T>(Attr attr) {
    return get2(attr.name);
  }

  dynamic operator [](String name) {
    return _valueMap[name];
  }

  void operator []=(String name, dynamic value) {
    _valueMap[name] = value;
  }

  RawData copy() {
    return RawData.fromMap(_valueMap);
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
}

///对原始数据的封装
class DataNode extends Disposable with StateMix, NodePropsMix {
  ///原始数据
  final RawData data;

  ///该节点所属的Geom
  Geom geom;

  ///全局索引
  int globalIndex = -1;

  ///数据索引
  int dataIndex = 0;

  ///优先级
  int priority;

  ///===============布局和绘制使用的属性==================
  Map<Dim, dynamic> _rawDataMap = {};

  ///存储布局结果
  LayoutResult layoutValue = const LayoutResult();
  CShape shape = EmptyShape.none;
  AreaStyle fillStyle = AreaStyle.empty;
  LineStyle sideStyle = LineStyle.empty;
  Text2? label;

  DataNode(
    this.geom,
    this.data, {
    double? value,
    this.priority = 0,
    int? index,
    int? deep,
  }) {
    if (index != null) {
      this.index = index;
    }
    if (deep != null) {
      this.deep = deep;
    }
    if (value != null) {
      this.value = value;
    }
    each(geom.allPos, (p0, p1) {
      _rawDataMap[p0.dim] = data.get2(p0.field);
    });
  }

  dynamic getRawData(Dim dim) {
    return _rawDataMap[dim];
  }

  void updateRawData(Dim dim, dynamic data) {
    _rawDataMap[dim] = data;
  }

  void resetRawData() {
    Map<Dim, dynamic> dm = {};
    each(geom.allPos, (p0, p1) {
      dm[p0.dim] = data.get2(p0.field);
    });
    _rawDataMap = dm;
  }

  ///辅助属性
  String get id => data.id;

  String get groupId => data.groupId ?? id;

  String getGroupCategory([Dim dim = Dim.x]) {
    var raw = getRawData(dim);
    if (raw == null) {
      return "";
    }
    return raw.toString();
  }

  String getStackId([Fun2<DataNode, String?>? stackIdFun]) {
    String? id = stackIdFun?.call(this);
    if (id == null || id.isEmpty) {
      id = data.get2("stackId");
    }
    if (id == null || id.isEmpty) {
      return this.id;
    }
    return id;
  }

  void render(Canvas2 canvas, Paint paint) {
    shape.render(canvas, paint, fillStyle);
    shape.render(canvas, paint, sideStyle);
    label?.render(canvas, paint, LineStyle.empty);
  }

  bool contains(Offset offset) {
    if (shape.contains(offset)) {
      return true;
    }
    return false;
  }

  bool updateStatus(Context context, Iterable<NodeState>? remove, Iterable<NodeState>? add) {
    if ((remove == null || remove.isEmpty) && (add == null || add.isEmpty)) {
      return false;
    }

    if (equalSet<NodeState>(remove, add)) {
      return false;
    }

    if (remove != null) {
      removeStates(remove);
    }

    if (add != null) {
      addStates(add);
    }

    sendStateChangeEvent(context);
    updateStyle(context);
    return true;
  }

  void updateStyle(Context context) {
    fillStyle = geom.pickFillStyle(this, 1);
    sideStyle = geom.pickSideStyle(this, 1);
    label?.style = geom.pickLabelStyle(this);
    label?.update();
  }

  void sendStateChangeEvent(Context context) {
    if (context.hasEventListener(EventType.dataStatusChanged)) {
      context.dispatchEvent(DataStatusChangeEvent(data, status));
    }
  }

  Pair<CShape, CStyle> pickStyle() {
    return Pair(shape, fillStyle);
  }

  @override
  void dispose() {
    super.dispose();
    cleanState();
    label = null;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is DataNode && other.id == id;
  }

  ///固定的值访问
  double? get fx => data.getAttr2(Attr.fx);

  double? get fy => data.getAttr2(Attr.fy);

  double? get fixValue => data.getAttr2(Attr.fixValue);

  PosMap get xPos => geom.pos(Dim.x);

  AxisDim get xAxisDim => xPos.axisDim;

  PosMap get yPos => geom.pos(Dim.y);

  AxisDim get yAxisDim => yPos.axisDim;

  String get coordId => geom.coordId;

  GeomType get geomType => geom.geomType;
}