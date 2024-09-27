import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class IntervalView extends BasePointView<IntervalGeom> {
  IntervalView(super.context, super.series);

  @override
  LayoutResult layoutSingleNode(CoordView coord, DataNode node) {
    if (coord is CalendarCoord) {
      throw UnsupportedError("Interval Geom not Support in CalendarCoord");
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

  @override
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
    return Attrs();
  }

  @override
  Attrs onBuildAnimateEndAttrs(DataNode node, DiffType type) {
    return Attrs();
  }
}
