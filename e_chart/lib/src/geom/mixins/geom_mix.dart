import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///数据映射图形描述信息
mixin GeomMix {
  ///这里是因为很多时候一个数据的映射维度不止一个维度或两个维度
  final Map<Dim, PosMap> _posMap = {};
  final List<PosMap> _posList = [];

  PosMap pos(Dim dim) {
    return _posMap[dim]!;
  }

  PosMap? posNull(Dim dim) {
    return _posMap[dim];
  }

  PosMap get xPos => pos(Dim.x);

  PosMap get yPos => pos(Dim.y);

  PosMap get firstPos => xPos;

  List<PosMap> get allPos {
    return _posList;
  }

  void addPos(PosMap map) {
    _posMap[map.dim] = map;
    _posList.remove(map);
    _posList.add(map);
  }

  void clearPos() {
    _posMap.clear();
    _posList.clear();
  }

  Map<PosMap, dynamic> mapData(RawData data) {
    Map<PosMap, dynamic> resultMap = {};
    for (var pos in _posList) {
      resultMap[pos] = data.get2(pos.field);
    }
    return resultMap;
  }

  dynamic mapData2(RawData data, Dim dim) {
    var pos = _posList.findOrNull((p0) => p0.dim == dim);
    if (pos == null) {
      return null;
    }
    return data.get2(pos.field);
  }

  SpecPick<AreaStyle>? fillStyleSpec;

  SpecPick<LineStyle>? sideStyleSpec;

  SpecPick<LabelStyle>? labelStyleSpec;

  SpecPick<double>? sizeSpec;

  SpecPick<double>? opacitySpec;

  Fun2<DataNode, CShape>? shapeSpec;

  ShapeType shapeType = ShapeType.circle;
  Attrs? shapeAttrs;

  AreaStyle pickFillStyle(DataNode node, double ratio) {
    return fillStyleSpec?.pick(node, node.data, ratio) ?? AreaStyle.empty;
  }

  LineStyle pickSideStyle(DataNode node, double ratio) {
    return sideStyleSpec?.pick(node, node.data, ratio) ?? LineStyle.empty;
  }

  LabelStyle pickLabelStyle(DataNode node) {
    return labelStyleSpec?.pick(node, node.data, 1) ?? LabelStyle.empty;
  }

  Size pickSize(DataNode node, double ratio) {
    double? w = node.data.getAttr2(Attr.fixWidth);
    double? h = node.data.getAttr2(Attr.fixHeight);
    var sizeSpec = this.sizeSpec;
    if (w == null) {
      if (sizeSpec != null) {
        w = sizeSpec.pick(node, node.data, ratio);
      } else {
        w = 16;
      }
    }
    if (h == null) {
      if (sizeSpec != null) {
        h = sizeSpec.pick(node, node.data, ratio);
      } else {
        h = 16;
      }
    }
    return Size(w, h);
  }

  CShape pickShape(DataNode node) {
    var spec = shapeSpec;
    if (spec != null) {
      return spec.call(node);
    }
    return shapeFactory.build(node, shapeAttrs, shapeType);
  }
}

///负责存储位置映射关系
class PosMap {
  final Dim dim;
  final int dimIndex;
  final String field;

  const PosMap(this.field, this.dimIndex, this.dim);

  AxisDim toAxisDim() {
    return AxisDim.of(dim, dimIndex);
  }

  AxisDim get axisDim {
    return AxisDim.of(dim, dimIndex);
  }

  @override
  String toString() {
    return "PosVar['dim':${dim.name},'dimIndex':$dimIndex,'field':$field]";
  }

  @override
  int get hashCode {
    return Object.hash(dim, dimIndex, field);
  }

  @override
  bool operator ==(Object other) {
    return other is PosMap && other.dim == dim && other.dimIndex == dimIndex && field == other.field;
  }
}
