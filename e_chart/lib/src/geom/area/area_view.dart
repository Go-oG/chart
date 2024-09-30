import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///Area类型
class AreaView extends PathView<AreaGeom> {
  AreaView(super.context, super.geom);

  @override
  Attrs onBuildAnimateStarAttrs(DataNode node, DiffType type) {
    var map = node.pickXY();
    map[Attr.scale] = type == DiffType.add ? 0 : 1;
    return map;
  }

  @override
  Attrs onBuildAnimateEndAttrs(DataNode node, DiffType type) {
    var attr = node.pickXY();
    attr[Attr.scale] = type == DiffType.remove ? 0 : 1;
    return attr;
  }

  @override
  void mergePath(List<DataNode> nodeList) {
    List<List<DataNode>> groupList = groupByGroupId(nodeList);

    List<CombineShape> shapeList = [];
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
      shapeList.add(CombineShape(list.first.style.copy(), area, list));
    });
    combineShapeList = shapeList;
  }

}
