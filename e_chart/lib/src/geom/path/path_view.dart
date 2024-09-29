import 'dart:ui';

import '../../../e_chart.dart';

class PathView extends PointView<PathGeom> {
  PathView(super.context, super.series);

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList) {
    mergePath(nodeList);
  }

  @override
  void onAnimateFrameUpdate(List<DataNode> list, double t) {
    mergePath(list);
    super.onAnimateFrameUpdate(list, t);
  }

  void mergePath(List<DataNode> nodeList) {
    List<List<DataNode>> groupList = groupNode(nodeList);
    List<CombineShape> shapeList = [];
    for (var list in groupList) {
      List<Offset> offsetList = List.from(list.map((e) => Offset(e.x, e.y)));
      var line = Line(offsetList, smooth: geom.smooth, dashList: geom.dashList, disDiff: geom.disDiff);
      //TODO 样式
      shapeList.add(CombineShape(list.first.style, line, list));
    }
    combineShapeList = shapeList;
  }

  ///分组数据
  List<List<DataNode>> groupNode(Iterable<DataNode> nodeList) {
    Map<String, List<DataNode>> map = {};
    for (var item in nodeList) {
      var groupId = item.groupId;
      var list = map[groupId] ?? [];
      map[groupId] = list;
      list.add(item);
    }

    for (var entry in map.entries) {
      var list = entry.value;
      if (list.length < 2) {
        continue;
      }
      sortGroupList(list);
    }

    List<String> keys = List.from(map.keys);
    keys.sort((a, b) {
      return map[a]!.first.globalIndex.compareTo(map[b]!.first.globalIndex);
    });

    List<List<DataNode>> rl = [];
    for (var key in keys) {
      rl.add(map[key]!);
    }
    return rl;
  }

  void sortGroupList(List<DataNode> list) {
    list.sort((a, b) {
      return a.globalIndex.compareTo(b.globalIndex);
    });
  }
}
