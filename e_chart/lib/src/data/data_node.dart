import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///原始数据的映射
///一个DataNode 对应一个原始数据
class DataNode extends Disposable with StateMix, AttrMixin {
  late final NormalizeData _data;

  ///该节点所属的Geom
  Geom geom;

  ///全局索引
  int globalIndex = -1;

  ///数据索引
  int dataIndex = 0;

  ///优先级
  int priority;

  /// 形状由布局确定(实际确定了shape)
  CShape shape = EmptyShape.none;
  final NodeStyle style = NodeStyle();

  Text2? label;

  DataNode(this.geom, RawData data, {double? value, this.priority = 0, int? index, int? deep}) {
    _data = NormalizeData(data);
    if (index != null) {
      this.index = index;
    }
    if (deep != null) {
      this.deep = deep;
    }
    if (value != null) {
      this.value = value;
    }
  }

  dynamic getRawData(Dim dim) => _data.getRawData(geom, dim);

  List<dynamic> getRawData2(Dim dim) {
    var raw = getRawData(dim);
    if (raw is List) {
      return raw;
    }
    return [raw];
  }

  String groupCategory([Dim dim = Dim.x]) {
    var raw = getRawData(dim);
    if (raw == null) {
      return "";
    }
    return raw.toString();
  }

  String stackId([Fun2<DataNode, String?>? stackIdFun]) {
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
    var sp = shape;
    style.render(canvas, paint, sp);
    label?.render(canvas, paint, LineStyle.empty);
  }

  bool contains(Offset offset) {
    var sp = shape;
    if (sp.contains(offset)) {
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
    style.fill(geom.pickFillStyle(this, 1), geom.pickSideStyle(this, 1));
    label?.style = geom.pickLabelStyle(this);
    label?.markDirty();
  }

  void sendStateChangeEvent(Context context) {
    if (context.hasEventListener(EventType.dataStatusChanged)) {
      context.dispatchEvent(DataStatusChangeEvent(data, status));
    }
  }

  @override
  void dispose() {
    super.dispose();
    cleanState();
    label = null;
  }

  RawData get data => _data.raw;

  NormalizeData get normalize => _data;

  ///辅助属性
  String get id => data.id;

  String get groupId => data.groupId ?? id;

  PosMap get xPos => geom.pos(Dim.x);

  AxisDim get xAxisDim => xPos.axisDim;

  PosMap get yPos => geom.pos(Dim.y);

  AxisDim get yAxisDim => yPos.axisDim;

  String get coordId => geom.coordId;

  GeomType get geomType => geom.geomType;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is DataNode && other.id == id;
  }
}

final class NormalizeData {
  final RawData raw;

  ///存储原始数据每个维度下 归一化后的比例[0-1]
  Map<Dim, List<double>> _normalizeMap = {};

  NormalizeData(this.raw);

  dynamic getRawData(Geom geom, Dim dim) {
    return raw.get2(geom.pos(dim).field);
  }

  List<double> get(Dim dim) {
    return _normalizeMap[dim]!;
  }

  List<double>? getNull(Dim dim) {
    return _normalizeMap[dim];
  }

  void set(Dim dim, List<double> data) {
    _normalizeMap[dim] = data;
  }

  void clear() {
    _normalizeMap = {};
  }
}

final class NodeStyle {
  AreaStyle? fillStyle;
  LineStyle? sideStyle;
  LabelStyle? labelStyle;

  NodeStyle({this.sideStyle, this.fillStyle, this.labelStyle});

  void fill(AreaStyle? fillStyle, LineStyle? sideStyle) {
    this.fillStyle = fillStyle;
    this.sideStyle = sideStyle;
  }

  void render(Canvas2 canvas, Paint paint, CShape shape) {
    var fs = fillStyle;
    if (fs != null) {
      shape.render(canvas, paint, fs);
    }
    var ss = sideStyle;
    if (ss != null) {
      shape.render(canvas, paint, ss);
    }
  }

  void dispose() {
    fillStyle = null;
    sideStyle = null;
  }

  NodeStyle copy() {
    return NodeStyle(sideStyle: sideStyle, fillStyle: fillStyle);
  }
}
