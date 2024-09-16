import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///Area类型
class AreaView extends BasePointView<AreaSeries> {
  AreaView(super.context, super.series);

  Map<Area, List<DataNode>> areaMap = {};

  @override
  void onLayoutPositionAndSize(List<DataNode> nodeList) {
    // TODO: implement onLayoutPositionAndSize
  }

  @override
  Attrs onAnimateLerpStar(DataNode node, DiffType type) {
    var map = node.pickXY();
    map[Attr.scale] = type == DiffType.add ? 0 : 1;
    return map;
  }

  @override
  Attrs onAnimateLerpEnd(DataNode node, DiffType type) {
    var attr = node.pickXY();
    attr[Attr.scale] = type == DiffType.remove ? 0 : 1;
    return attr;
  }

  @override
  void onAnimateLerpUpdate(DataNode node, Attrs s, Attrs e, double t, DiffType type) {
    node.x = lerpDouble(s[Attr.x], e[Attr.x], t)!;
    node.y = lerpDouble(s[Attr.y], e[Attr.y], t)!;
    node.scale = lerpDouble(s[Attr.scale], e[Attr.scale], t)!;
    super.onAnimateLerpUpdate(node, s, e, t, type);
  }

  @override
  void onAnimateFrameUpdate(List<DataNode> list, double t) {
    mergeAreas(list);
    super.onAnimateFrameUpdate(list, t);
  }

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList, bool isIntercept) {
    if (isIntercept) {
      return;
    }
    mergeAreas(nodeList);
  }

  void mergeAreas(List<DataNode> nodeList) {
    List<List<DataNode>> groupList = groupByGroupId(nodeList);
    Map<Area, List<DataNode>> resultMap = {};
    each(groupList, (list, index) {
      List<Offset> curList = List.from(list.map((e) => Offset(e.x, e.y)));
      if (curList.isEmpty) {
        return;
      }
      List<Offset> preList;
      if (index == 0) {
        preList = curList;
      } else {
        preList = List.from(groupList[index - 1].map((e) => Offset(e.x, e.y)));
      }
      var area = Area(curList, preList, upSmooth: geom.smooth, downSmooth: geom.smooth);
      resultMap[area] = list;
    });
    areaMap = resultMap;
  }

  @override
  void onDraw(Canvas2 canvas) {
    var style = const LineStyle();
    var fillStyle = const AreaStyle();
    for (var pair in areaMap.entries) {
      style.drawPath(canvas, mPaint, pair.key.path, pair.key.bound);
    }
    for (var pair in areaMap.entries) {
      for (var node in pair.value) {
        node.shape.render(canvas, mPaint, fillStyle);
      }
    }
  }
}
