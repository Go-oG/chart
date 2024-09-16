import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

class ThemeRiverTransform extends PointTransform {
  Direction direction;
  SNumber? minInterval;
  double smooth;

  ThemeRiverTransform({
    this.direction = Direction.horizontal,
    this.minInterval,
    this.smooth = 0.25,
  });

  num maxTransX = 0, maxTransY = 0;

  Map<Area, List<DataNode>> _areaMap = {};

  Map<Area, List<DataNode>> get areaShapes => _areaMap;

  @override
  void transform(Context context, double width, double height, List<DataNode> nodeList) {
    var groupList = groupByGroupId(nodeList);
    _areaMap = _layoutNode(groupList, width, height);
  }

  Map<Area, List<DataNode>> _layoutNode(List<List<DataNode>> groupList, double width, double height) {
    var base = _computeBaseline(groupList);
    List<double> baseLine = base['y0'];
    double tw = (direction == Direction.horizontal ? height : width) * 0.95;
    double ky = tw / base['max'];

    int n = groupList.length;
    int m = groupList[0].length;
    tw = direction == Direction.horizontal ? width : height;
    double iw = m <= 1 ? 0 : tw / (m - 1);
    var minInterval = this.minInterval;
    if (m > 1 && minInterval != null) {
      double minw = minInterval.convert(tw);
      if (iw < minw) {
        iw = minw;
      }
    }

    double baseY0;
    for (int j = 0; j < m; ++j) {
      baseY0 = baseLine[j] * ky;
      var node = groupList[0][j];
      _setItemLayout(node, 0, iw * j, baseY0, groupList[0][j].value * ky);
      for (int i = 1; i < n; ++i) {
        baseY0 += groupList[i - 1][j].value * ky;
        node = groupList[i][j];
        _setItemLayout(node, i, iw * j, baseY0, groupList[i][j].value * ky);
      }
    }

    Map<Area, List<DataNode>> shapeMap = {};
    for (int j = 0; j < groupList.length; j++) {
      var nodes = groupList[j];
      List<Offset> pList = [];
      List<Offset> pList2 = [];
      for (int i = 0; i < nodes.length; i++) {
        if (direction == Direction.horizontal) {
          pList.add(Offset(nodes[i].x, nodes[i].extra2));
          pList2.add(Offset(nodes[i].x, nodes[i].extra1 + nodes[i].extra2));
        } else {
          pList.add(Offset(nodes[i].extra2, nodes[i].x));
          pList2.add(Offset(nodes[i].extra1 + nodes[i].extra2, nodes[i].x));
        }
      }
      var shape = _buildShape(nodes, pList, pList2);
      shapeMap[shape] = nodes;
    }
    return shapeMap;
  }

  Map<String, dynamic> _computeBaseline(List<List<DataNode>> data) {
    int layerNum = data.length;
    int pointNum = data[0].length;
    List<double> sums = [];
    double max = 0;

    ///按照时间序列 计算并保存每个序列值和，且和全局最大序列值和进行比较保留最大的
    for (int i = 0; i < pointNum; ++i) {
      double temp = 0;
      for (int j = 0; j < layerNum; ++j) {
        temp += data[j][i].value;
      }
      if (temp > max) {
        max = temp;
      }
      sums.add(temp);
    }

    ///计算每个序列与最大序列值差值的一半
    List<double> y0 = List.filled(pointNum, 0);
    for (int k = 0; k < pointNum; ++k) {
      y0[k] = (max - sums[k]) / 2;
    }

    max = 0;
    for (int l = 0; l < pointNum; ++l) {
      double sum = sums[l] + y0[l];
      if (sum > max) {
        max = sum;
      }
    }
    return {'y0': y0, 'max': max};
  }

  void _setItemLayout(DataNode node, int index, double px, double py0, double py) {
    node.index = index;
    node.x = px;
    node.y = py;
    node.extra1 = py;
    node.extra2 = py0;
  }

  Area _buildShape(List<DataNode> nodes, List<Offset> pList, List<Offset> pList2) {
    Area shape;
    if (direction == Direction.vertical) {
      shape = Area.vertical(pList, pList2, upSmooth: smooth, downSmooth: smooth);
    } else {
      shape = Area(pList, pList2, upSmooth: smooth, downSmooth: smooth);
    }

    List<Offset> polygonList = [];
    polygonList.addAll(pList);
    polygonList.addAll(pList2.reversed);

    Offset o1 = polygonList.first;
    Offset o2 = polygonList.last;
    if (direction == Direction.horizontal) {
      Offset offset = Offset(o1.dx, (o1.dy + o2.dy) * 0.5);
      //   label.updatePainter(offset: offset, align: Alignment.centerLeft);
    } else {
      Offset offset = Offset((o1.dx + o2.dx) / 2, o1.dy);
      //  label.updatePainter(offset: offset, align: Alignment.topCenter);
    }
    return shape;
  }
}
