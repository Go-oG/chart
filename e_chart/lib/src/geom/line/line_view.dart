import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///线条视图
///通常会进行排序等操作
class LineView extends PointView<LineGeom> {
  LineView(super.context, super.series);

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList, bool isIntercept) {
    if (isIntercept) {
      return;
    }
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

  @override
  void onDraw(Canvas2 canvas) {
    for (var shape in combineShapeList) {
      shape.style.render(canvas, mPaint, shape.shape);
    }
    super.onDraw(canvas);
  }

  void mergeLine(List<DataNode> nodeList) {
    List<CombineShape> shapeList = [];
    List<List<DataNode>> groupList = groupByGroupId(nodeList);
    var step = geom.lineType;
    for (var list in groupList) {
      List<Offset> offsetList = List.from(list.map((e) => Offset(e.x, e.y)));
      if (step != null) {
        offsetList = Line.step2(offsetList, step);
      }
      var line =
          Line(offsetList, smooth: (step == null ? geom.smooth : 0), dashList: geom.dashList, disDiff: geom.disDiff);

      ///TODO 样式应该需要更改
      shapeList.add(CombineShape(list.first.style.copy(), line, list));
    }
    combineShapeList = shapeList;
  }
}
