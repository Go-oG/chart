import 'dart:async';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
class IntervalView extends AnimateGeomView<IntervalGeom> {
  late DataStore<DataNode> _xStore;
  late DataStore<DataNode> _yStore;

  IntervalView(super.context, super.series) {
    _xStore = DataStore((e) {
      return e.normalize.getRawData(geom, Dim.x);
    });
    _yStore = DataStore((e) {
      return e.normalize.getRawData(geom, Dim.y);
    });
  }

  @override
  void onLayoutNodeList(List<DataNode> nodeList) {
    var coordView = findCoordView()!;
    for (var node in nodeList) {
      node.layoutResult = layoutSingleNode(coordView, node);
    }
  }

  LayoutResult layoutSingleNode(CoordView coord, DataNode node) {
    if (coord is! GridCoord && coord is! PolarCoord) {
      throw UnsupportedError("Interval Geom only support  GridCoord and PolarCoord");
    }
    var xScale = context.dataManager.getAxisScale(geom.coordId, node.xAxisDim);
    var yScale = context.dataManager.getAxisScale(geom.coordId, node.yAxisDim);
    var x = node.normalize.get(Dim.x);
    var y = node.normalize.get(Dim.y);
    if (coord is GridCoord) {
      List<double> xList = x.map((e) => coord.convert(node.xAxisDim, e)).toList();
      List<double> yList = y.map((e) => coord.convert(node.yAxisDim, e)).toList();
      if (xList.length <= 1 || yList.length <= 1) {
        if (yScale.isCategory) {
          if (xList.length <= 1) {
            xList = [xScale.range.first, xList.first];
          }
          if (yList.length <= 1) {
            yList = [yList.first - yScale.bandSize / 2, yList.first + yScale.bandSize / 2];
          }
        } else {
          if (xList.length <= 1) {
            xList = [xList.first - xScale.bandSize / 2, xList.first + xScale.bandSize / 2];
          }
          if (yList.length <= 1) {
            yList = [yScale.range.first, yList.first];
          }
        }
      }
      return RectLayoutResult(left: xList.first, top: yList.first, right: xList.last, bottom: yList.last);
    }
    if (coord is PolarCoord) {
      List<double> xList = x.map((e) => coord.convert(node.xAxisDim, e)).toList();
      List<double> yList = y.map((e) => coord.convert(node.yAxisDim, e)).toList();
      if (xList.length <= 1 || yList.length <= 1) {
        if (yScale.isCategory) {
          if (xList.length <= 1) {
            xList = [xScale.range.first, xList.first];
          }
          if (yList.length <= 1) {
            yList = [yList.first - yScale.bandSize / 2, yList.first + yScale.bandSize / 2];
          }
        } else {
          if (xList.length <= 1) {
            xList = [xList.first - xScale.bandSize / 2, xList.first + xScale.bandSize / 2];
          }
          if (yList.length <= 1) {
            yList = [yScale.range.first, yList.first];
          }
        }
      }

      var result = ArcLayoutResult();
      result.center = coord.center;
      result.innerRadius = xList.first;
      result.outRadius = xList.last;
      result.startAngle = yList.first;
      result.sweepAngle = yList.last - yList.first;
      result.cornerRadius = 0;
      result.padAngle = 0;
      return result;
    }

    return const LayoutResult();
  }

  @override
  Future<List<DataNode>> onClipPendingLayoutNodes(List<DataNode> newTotalDataSet) async {
    var coord = findCoordView();
    if (coord is! GridCoord) {
      return newTotalDataSet;
    }
    var yScale = context.dataManager.getAxisScale(geom.coordId, geom.yPos.axisDim);
    _xStore.parse(newTotalDataSet);
    _yStore.parse(newTotalDataSet);
    AxisDim dim;
    DataStore<DataNode> store;
    if (yScale.isCategory) {
      dim = geom.yPos.axisDim;
      store = _yStore;
    } else {
      dim = geom.xPos.axisDim;
      store = _xStore;
    }
    RangeInfo range = coord.getAxisViewportRange(dim);
    return store.getDataByRange(range);
  }

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList) {
    for (var node in nodeList) {
      RectLayoutResult ll = node.layoutResult as RectLayoutResult;
      node.shape = CRect(left: ll.left, top: ll.top, right: ll.right, bottom: ll.bottom);
      node.style.fillStyle=AreaStyle(color: randomColor());
    }
  }

  @override
  AnimateOption? getAnimateOption(LayoutType type, [int objCount = -1]) {
    // TODO: 先忽略动画相关的
    return null;
  }

}
