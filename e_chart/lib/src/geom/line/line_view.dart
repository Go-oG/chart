import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///线条视图
///通常会进行排序等操作
class LineView extends BasePointView<LineGeom> {
  LineView(super.context, super.series);

  List<Pair<Line, List<DataNode>>> lineList = [];

  @override
  void onLayoutPositionAndSize(List<DataNode> nodeList) {
    // TODO: implement onLayoutPositionAndSize
  }

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList, bool isIntercept) {
    if (isIntercept) {
      return;
    }
    mergeLine(nodeList);
  }

  @override
  Attrs onAnimateLerpStar(DataNode node, DiffType type) {
    var attr = node.pickXY();
    if (type == DiffType.add) {
      attr[Attr.y] = height;
    }
    return attr;
  }

  @override
  Attrs onAnimateLerpEnd(DataNode node, DiffType type) {
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

  void mergeLine(List<DataNode> nodeList) {
    List<Pair<Line, List<DataNode>>> lineList = [];
    List<List<DataNode>> groupList = groupByGroupId(nodeList);
    var step = geom.lineType;
    for (var list in groupList) {
      List<Offset> offsetList = List.from(list.map((e) => Offset(e.x, e.y)));

      if (step != null) {
        offsetList = Line.step2(offsetList, step);
      }

      var line =
          Line(offsetList, smooth: (step == null ? geom.smooth : 0), dashList: geom.dashList, disDiff: geom.disDiff);
      lineList.add(Pair(line, list));
    }
    this.lineList = lineList;
  }
}
