import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于绘制点集视图
class PointView<T extends PointGeom> extends BasePointView<T> {
  PointView(super.context, super.geom);

  @override
  LayoutResult layoutSingleNode(CoordView coord, DataNode node) {
    var xData = node.normalize.get(Dim.x);
    var yData = node.normalize.get(Dim.y);
    if (coord is CalendarCoord) {
      DateTime? time = node.getRawData(Dim.x);
      time ??= node.getRawData(Dim.y);
      if (time == null) {
        throw ArgumentError("time is null");
      }
      var rect = coord.convert2(time);
      return RectLayoutResult(left: rect.left, top: rect.top, right: rect.right, bottom: rect.bottom);
    }

    var x = coord.convert(node.xAxisDim, xData.first);
    var y = coord.convert(node.yAxisDim, yData.first);

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

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList) {
    var coordView = findCoordView()!;
    for (var node in nodeList) {
      node.size = layoutSingleNodeSize(coordView, node);
    }
    super.onLayoutNodeEnd(nodeList);
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
  Attrs onBuildAnimateStarAttrs(DataNode node, DiffType type) {
    var attr = {Attr.x: node.x, Attr.y: node.y};
    attr[Attr.scale] = type == DiffType.add ? 0 : 1;
    return attr;
  }

  @override
  Attrs onBuildAnimateEndAttrs(DataNode node, DiffType type) {
    var attr = {Attr.x: node.x, Attr.y: node.y};
    attr[Attr.scale] = type == DiffType.remove ? 0 : 1;
    return attr;
  }
}
