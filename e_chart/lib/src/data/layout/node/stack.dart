import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:statistics/statistics.dart';

///实现Stack相关
abstract class BaseStack extends DataTransform {
  StackType type;
  bool percent;
  Fun2<DataNode, String?>? stackIdFun;

  BaseStack({
    this.stackIdFun,
    this.type = StackType.split,
    this.percent = false,
  });

  @override
  void onAfterConvertRawData(Geom geom, List<DataNode> nodeList) {
    Map<String, GroupNode> groupMap = {};
    for (var node in nodeList) {
      var cat = node.groupCategory(stackDim.invert);
      var groupNode = groupMap[cat] ?? GroupNode(cat);
      groupMap[cat] = groupNode;
      groupNode.add(node.stackId(stackIdFun), node);
    }
    for (var groupNode in groupMap.values) {
      for (var col in groupNode.columns.values) {
        _stackData(col);
      }
    }
  }

  void _stackData(ColumnNode colNode) {
    var dataList = colNode.dataList;
    if (dataList.isEmpty) {
      return;
    }

    final dim = stackDim;
    if (dataList.length == 1) {
      if (!percent) {
        return;
      }
      var node = dataList.first;
      var raw = node.getRawData(stackDim);
      if (raw == null || (raw is List && raw.isEmpty)) {
        node.setNormalizeData2(dim, [0, 0]);
        return;
      }
      node.setNormalizeData2(dim, [0, 100]);
      return;
    }

    ///统计数据
    Map<DataNode, Statistics> statisticsMap = _statisticsData(dataList);

    List<DataNode> positiveList = [];
    List<DataNode> negativeList = [];
    List<DataNode> crossList = [];
    each(dataList, (node, p1) {
      var statistics = statisticsMap[node];
      if (statistics == null) {
        return;
      }
      if (statistics.min >= 0) {
        positiveList.add(node);
      } else if (statistics.max <= 0) {
        negativeList.add(node);
      } else {
        crossList.add(node);
      }
    });

    if (type == StackType.split) {
      _splitHandle(positiveList, statisticsMap, true);
      _splitHandle(negativeList, statisticsMap, false);
      _sumHandle(crossList, statisticsMap);
      if (percent) {
        _percentData(positiveList);
        _percentData(negativeList);
        _percentData(crossList);
      }
    } else {
      List<DataNode> tmpList = List.from(dataList);
      tmpList.removeWhere((element) => statisticsMap[element] == null);
      _sumHandle(tmpList, statisticsMap);
      if (percent) {
        _percentData(tmpList);
      }
    }
  }

  Map<DataNode, Statistics> _statisticsData(Iterable<DataNode> dataList) {
    Map<DataNode, Statistics> dataMap = {};
    each(dataList, (node, p1) {
      List<num> nl = [];
      var raw = node.getRawData(stackDim);
      if (raw is List) {
        for (var raw2 in raw) {
          if (raw2 is num) {
            nl.add(raw2);
            continue;
          }
          throw ChartError("堆叠的数据只能为num类型");
        }
      } else {
        if (raw is num) {
          nl.add(0);
          nl.add(raw);
        } else {
          throw ChartError("堆叠的数据只能为num类型");
        }
      }

      if (nl.isNotEmpty) {
        dataMap[node] = nl.statistics;
      }
    });
    return dataMap;
  }

  void _sumHandle(List<DataNode> dataList, Map<DataNode, Statistics> statisticsMap) {
    if (dataList.isEmpty) {
      return;
    }
    var first = dataList.first;
    num up = statisticsMap[first]!.max;
    each(dataList, (node, i) {
      if (i == 0) {
        return;
      }
      var statistics = statisticsMap[node]!;
      var partList = toList(node.getRawData(stackDim));
      var minV = statistics.min.toDouble();
      List<double> dl = [];
      for (var part in partList) {
        var raw = part as num;
        dl.add(up + raw - minV);
      }
      node.setNormalizeData2(stackDim, dl);
      up = up + statistics.max - minV;
    });
  }

  void _splitHandle(List<DataNode> dataList, Map<DataNode, Statistics> statisticsMap, bool positive) {
    if (dataList.isEmpty) {
      return;
    }
    if (positive) {
      _sumHandle(dataList, statisticsMap);
      return;
    }
    var first = dataList.first;
    num down = statisticsMap[first]!.min;
    each(dataList, (node, i) {
      if (i == 0) {
        return;
      }
      var statistics = statisticsMap[node]!;
      var partList = toList(node.getRawData(stackDim));
      var minV = statistics.min;

      List<double> dl = [];
      for (var part in partList) {
        var raw = part as num;
        dl.add(down - (raw - minV).toDouble());
      }
      node.setNormalizeData2(stackDim, dl);
      down = down - (statistics.max - minV);
    });
  }

  void _percentData(List<DataNode> dataList) {
    if (dataList.isEmpty) {
      return;
    }
    num minValue = double.maxFinite;
    num maxValue = double.minPositive;

    for (var node in dataList) {
      for (var part in toList(node.getRawData(stackDim))) {
        var vv = part as num;
        minValue = min(vv, minValue);
        maxValue = max(vv, maxValue);
      }
    }

    var range = (maxValue - minValue);

    for (var node in dataList) {
      List<double> dl = [];
      for (var part in toList(node.getRawData(stackDim))) {
        var vv = part as num;
        var dir = vv >= 0 ? 1 : -1;
        dl.add(100 * dir * (vv - minValue) / range);
      }
      node.setNormalizeData2(stackDim, dl);
    }
  }

  Dim get stackDim;
}

class StackY extends BaseStack {
  StackY({
    super.stackIdFun,
    super.percent,
    super.type,
  });

  @override
  Dim get stackDim => Dim.y;
}

class StackX extends BaseStack {
  StackX({
    super.stackIdFun,
    super.percent,
    super.type,
  });

  @override
  Dim get stackDim => Dim.x;
}
