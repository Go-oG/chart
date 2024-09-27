import 'dart:ui';

import '../../../e_chart.dart';

class PathView extends PointView<PathGeom> {
  PathView(super.context, super.series);

  List<Pair<Line, List<DataNode>>> lineList = [];

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList, bool isIntercept) {
    if (isIntercept) {
      return;
    }
    mergePath(nodeList);
  }

  @override
  void onDraw(Canvas2 canvas) {
    var style = const LineStyle();
    var fillStyle = const AreaStyle();
    for (var pair in lineList) {
      style.drawPath(canvas, mPaint, pair.first.path, pair.first.bound);
    }

    for (var pair in lineList) {
      for (var node in pair.second) {
        node.shape.render(canvas, mPaint, fillStyle);
      }
    }
  }

  @override
  void onAnimateFrameUpdate(List<DataNode> list, double t) {
    mergePath(list);
    super.onAnimateFrameUpdate(list, t);
  }

  void mergePath(List<DataNode> nodeList) {
    List<Pair<Line, List<DataNode>>> lineList = [];
    List<List<DataNode>> groupList = groupNode(nodeList);

    for (var list in groupList) {
      List<Offset> offsetList = List.from(list.map((e) => Offset(e.x, e.y)));
      var line = Line(offsetList, smooth: geom.smooth, dashList: geom.dashList, disDiff: geom.disDiff);
      lineList.add(Pair(line, list));
    }
    this.lineList = lineList;
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
