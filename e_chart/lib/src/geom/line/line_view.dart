import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///线条视图
///通常会进行排序等操作
class LineView extends PointView<LineGeom> {
  LineView(super.context, super.series);

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList) {
    mergeLine(nodeList);
  }

  @override
  Attrs onBuildAnimateStarAttrs(DataNode node, DiffType type) {
    var attr = node.pickXY();
    if (type == DiffType.add) {
      attr[Attr.y] = height;
    }
    return attr;
  }

  @override
  Attrs onBuildAnimateEndAttrs(DataNode node, DiffType type) {
    var attr = node.pickXY();
    if (type == DiffType.remove) {
      attr[Attr.y] = height * 2;
    }
    return attr;
  }

  @override
  void onAnimateLerpUpdate(DataNode node, Attrs s, Attrs e, double t, DiffType type) {
    node.x = lerpDouble(s[Attr.x], e[Attr.x], t)!;
    node.y = lerpDouble(s[Attr.y], e[Attr.y], t)!;
  }

  @override
  void onAnimateFrameUpdate(List<DataNode> list, double t) {
    mergeLine(list);
    super.onAnimateFrameUpdate(list, t);
  }

  void mergeLine(List<DataNode> nodeList) {}
}
