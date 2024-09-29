import 'package:e_chart/e_chart.dart';

typedef CoordId = String;
typedef NodeId=String;

final class DataManager extends Disposable {
  ///存放所有元素的映射
  Map<NodeId, DataNode> _nodeMap = {};

  Map<CoordId, Coord> _coordMap = {};

  ///按照坐标域-geom进行数据分类
  Map<CoordId, Map<GeomType, List<DataNode>>> _nodeCatMap = {};

  ///存放轴的极值信息(需要注意层叠的情况(例如柱状图单个层叠))
  Map<CoordId, Map<AxisDim, DataExtreme>> _extremeMap = {};

  ///存放坐标轴的映射信息
  ///<coordId>
  Map<CoordId, Map<AxisDim, BaseScale>> _axisScaleMap = {};

  Coord getCoord(String coordId) {
    return _coordMap[coordId]!;
  }

  DataNode? getNode(NodeId id) => _nodeMap[id];

  List<DataNode> getCoordNodes(CoordScope coord) {
    var tmp = _nodeCatMap[coord];
    if (tmp == null) {
      return [];
    }

    Set<DataNode> resultList = <DataNode>{};
    for (var item in tmp.values) {
      resultList.addAll(item);
    }
    List<DataNode> rl = resultList.toList();
    rl.sort((a, b) {
      return a.globalIndex.compareTo(b.globalIndex);
    });
    return rl;
  }

  List<DataNode> getNodesByGeom(String coordId, GeomType type) {
    return _nodeCatMap[coordId]?[type] ?? [];
  }

  BaseScale getAxisScale(String coordId, AxisDim axisDim) {
    return _axisScaleMap[coordId]![axisDim]!;
  }

  BaseScale getAxisScale2(String coordId, PosMap pos) {
    return _axisScaleMap[coordId]![pos.axisDim]!;
  }

  ///经过处理后所有的数据在各自的坐标系范围内都有其百分比位置
  ///
  Future<void> parse(Context context, List<Coord> coordList, List<Geom> list) async {
    ///Step1 记录坐标系(没有包含自定义坐标)
    var coordMap = _recordCoord(coordList);
    Map<Geom, List<DataTransform>> transformMap = _collectTransform(list);

    ///Hook 1
    for (var entry in transformMap.entries) {
      var dataSet = entry.key.dataSet;
      for (var item in dataSet) {
        item.unfreeze();
      }

      for (var trans in entry.value) {
        dataSet = trans.onBeforeConvertRawData(entry.key, dataSet);
      }

      for (var item in dataSet) {
        item.freeze();
      }

      entry.key.dataSet = dataSet;
    }

    ///Step2 转换数据
    var pair = await _convertRawData(list);
    var nodeMap = pair.first;
    var geomNodeMap = pair.second;

    ///Hook2
    for (var entry in transformMap.entries) {
      var list = geomNodeMap[entry.key];
      if (list == null) {
        continue;
      }
      for (var trans in entry.value) {
        trans.onAfterConvertRawData(entry.key, list);
      }
    }

    ///Step3 切分数据
    ///按照坐标系-> geomType 划分数据
    var divisionMap = await _divisionalData(nodeMap.values);

    ///Hook3
    for (var geom in list) {
      var transList = transformMap[geom]!;
      for (var trans in transList) {
        trans.onBeforeComputeExtreme2(nodeMap.values, coordMap);
      }
    }

    ///Step4 收集极值信息
    var extremeMap = await _collectExtremeData(nodeMap.values, coordMap);

    ///Hook4
    for (var geom in list) {
      var transList = transformMap[geom]!;
      for (var trans in transList) {
        trans.onBeforeBuildScale(nodeMap.values, coordMap, extremeMap);
      }
    }

    ///Step5 生成比例尺
    var axisMap = _niceAxis(coordMap, extremeMap);
    _coordMap = coordMap;
    _nodeMap = nodeMap;
    _nodeCatMap = divisionMap;
    _extremeMap = extremeMap;
    _axisScaleMap = axisMap;

    ///Hook5
    for (var geom in list) {
      var transList = transformMap[geom]!;
      var nodeList = geomNodeMap[geom]!;
      for (var trans in transList) {
        trans.onAfterBuildScale(context, geom, nodeList);
      }
    }

  }

  Map<Geom, List<DataTransform>> _collectTransform(List<Geom> geomList) {
    Map<Geom, List<DataTransform>> map = {};
    for (var geom in geomList) {
      map[geom] = geom.dataTransformList;
    }
    return map;
  }

  ///step1 记录坐标系信息
  Map<String, Coord> _recordCoord(List<Coord> coordList) {
    Map<String, Coord> map = {};
    each(coordList, (coord, index) {
      map[coord.id] = coord;
    });
    return map;
  }

  ///step2 转换数据
  Future<Pair<Map<String, DataNode>, Map<Geom, List<DataNode>>>> _convertRawData(List<Geom> geomList) async {
    Map<String, DataNode> map = {};
    Map<Geom, List<DataNode>> geomMap = {};
    int index = 0;
    int geomIndex = 0;
    for (var geom in geomList) {
      geom.geomIndex = geomIndex;
      geomIndex += 1;
      List<DataNode> nodeList = [];
      geomMap[geom] = nodeList;
      for (var item in geom.dataSet) {
        var node = geom.toNode(item);
        node.globalIndex = index;
        index += 1;
        map[item.id] = node;
        nodeList.add(node);
      }
    }

    return Pair(map, geomMap);
  }

  /// Step3 划分数据将其分割在不同的坐标域里面
  Future<Map<CoordId, Map<GeomType, List<DataNode>>>> _divisionalData(Iterable<DataNode> nodeList) async {
    Map<CoordId, Map<GeomType, List<DataNode>>> resultMap = {};
    for (var node in nodeList) {
      var childMap = resultMap[node.coordId] ?? {};
      resultMap[node.coordId] = childMap;
      var tmpList = childMap[node.geomType] ?? [];
      childMap[node.geomType] = tmpList;
      tmpList.add(node);
    }
    return resultMap;
  }

  ///Step5 收集数据映射信息
  Future<Map<String, Map<AxisDim, DataExtreme>>> _collectExtremeData(
      Iterable<DataNode> nodeList, Map<String, Coord> coordMap) async {
    Map<String, Map<AxisDim, DataExtreme>> resultMap = {};
    Map<AxisDim, DataExtreme> extremeFun() {
      return {};
    }

    for (var node in nodeList) {
      var coordId = node.coordId;
      var extremeMap = resultMap.get3(coordId, extremeFun);
      for (var pos in node.geom.allPos) {
        var axisDim = pos.axisDim;
        var extreme = extremeMap[axisDim] ?? DataExtreme([], [], []);
        extremeMap[axisDim] = extreme;
        extreme.addData(node.getRawData(axisDim.dim));
      }
    }

    List<Future<dynamic>> futureList = [];

    ///合并极值信息
    for (var e1 in resultMap.entries) {
      futureList.addAll(e1.value.entries
          .map((e2) => Future(() {
                e2.value.merge();
              }))
          .toList());
    }

    await Future.wait(futureList);

    return resultMap;
  }

  ///Step6 生成坐标轴的比例尺
  Map<String, Map<AxisDim, BaseScale>> _niceAxis(
    Map<String, Coord> coordMap,
    Map<String, Map<AxisDim, DataExtreme>> extremeMap,
  ) {
    Map<String, Map<AxisDim, BaseScale>> resultMap = {};
    for (var entry in extremeMap.entries) {
      var coord = coordMap[entry.key];
      if (coord == null) {
        continue;
      }

      for (var item in entry.value.entries) {
        var axisDim = item.key;
        var extreme = item.value;
        var config = coord.getAxisConfig(axisDim);
        var scale = config.toScale([0, 1.0], extreme.getExtreme(config.type), config.splitNumber);
        resultMap.get2(coord.id, {})[axisDim] = scale;
      }
    }


    return resultMap;
  }

  @override
  void dispose() {
    _nodeMap = {};
    _coordMap = {};
    _nodeCatMap = {};
    _extremeMap = {};
    _axisScaleMap = {};
    super.dispose();
  }
}
