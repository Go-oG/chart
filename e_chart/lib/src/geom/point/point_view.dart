import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于绘制点集视图
class PointView extends BasePointView<PointGeom> {
  PointView(super.context, super.series);

  @override
  void onLayoutPositionAndSize(List<DataNode> nodeList) {
    var coord = findCoordView();
    if (coord == null) {
      return;
    }
    for (var node in nodeList) {
      node.layoutValue = layoutSingleNode(coord, node);
      node.size = layoutSingleNodeSize(coord, node);
    }
  }

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList, bool isIntercept) {
    if (isIntercept) {
      return;
    }
    //构建Shape
    for (var node in nodeList) {
      node.shape = geom.pickShape(node);
    }
  }

  ///对单个节点布局属性
  LayoutResult layoutSingleNode(CoordView coord, DataNode node) {
    if (coord is CalendarCoord) {
      DateTime? time = node.getRawData(Dim.x);
      time ??= node.getRawData(Dim.y);
      if (time == null) {
        throw ArgumentError("time is null");
      }
      var x = coord.convert2(node.xAxisDim, time);
      var y = coord.convert2(node.yAxisDim, time);
      return OffsetLayoutResult(x: x, y: y);
    }
    var x = node.getRawData(Dim.x);
    var y = node.getRawData(Dim.y);
    x = (coord as dynamic).convert2(node.xAxisDim, x);
    y = (coord as dynamic).convert2(node.yAxisDim, y);
    if (coord is GridCoord || coord is ParallelCoord) {
      return OffsetLayoutResult(x: x, y: y);
    }
    if (coord is PolarCoord) {
      return PolarLayoutResult(center: coord.center, radius: x, angle: y);
    }
    if (coord is RadarCoord) {
      return PolarLayoutResult(center: coord.center, radius: x, angle: y);
    }
    if (coord is SingleCoord) {
      return OffsetLayoutResult(x: x, y: 0);
    }
    return const LayoutResult();
  }

  Size layoutSingleNodeSize(CoordView coord, DataNode node) {
    if (coord is CalendarCoord) {
      return coord.cellSize;
    }

    var xScale = context.dataManager.getAxisScale(geom.coordId, node.xAxisDim);
    var yScale = context.dataManager.getAxisScale(geom.coordId, node.yAxisDim);

    var xRatio = xScale.normalize(node.getRawData(Dim.x));
    var yRatio = yScale.normalize(node.getRawData(Dim.y));

    var x = geom.pickSize(node, xRatio);
    var y = geom.pickSize(node, yRatio);

    return Size(x.width, y.height);
  }

  @override
  Attrs onAnimateLerpStar(DataNode node, DiffType type) {
    var attr = node.pickXY();
    attr[Attr.scale] = type == DiffType.add ? 0 : 1;
    return attr;
  }

  @override
  Attrs onAnimateLerpEnd(DataNode node, DiffType type) {
    var attr = node.pickXY();
    attr[Attr.scale] = type == DiffType.remove ? 0 : 1;
    return attr;
  }

  @override
  void onAnimateLerpUpdate(DataNode node, Attrs s, Attrs e, double t, DiffType type) {
    node.fillFromAttr(s.lerp(e, t));
  }
}
