import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class BasePointView<T extends Geom> extends AnimateGeomView<T> {
  BasePointView(super.context, super.series);

  @override
  void onLayoutPositionAndSize(List<DataNode> nodeList) {
    var coord = findCoordView();
    if (coord == null) {
      return;
    }
    for (var node in nodeList) {
      var layoutResult=layoutSingleNode(coord, node);
      var size=layoutSingleNodeSize(coord, node);
      node.layoutResult = layoutResult;
      node.size =size;
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

  LayoutResult layoutSingleNode(CoordView coord, DataNode node);

  Size layoutSingleNodeSize(CoordView coord, DataNode node);

  @override
  void onAnimateLerpUpdate(DataNode node, Attrs s, Attrs e, double t, DiffType type) {
    node.fillFromAttr(s.lerp(e, t));
  }

  @override
  void onClickAfter(DataNode? now, DataNode? old) {
    repaint();
    // List<DataNode> oldList = [];
    // if (old != null) {
    //   oldList.add(old);
    // }
    // List<DataNode> newList = [];
    // if (now != null) {
    //   newList.add(now);
    // }
    //
    // sortList(showNodeList);
    //
    //
    // List<ChartTween> tl = [];
    // for (var diff in list) {
    //   var node = diff.data;
    //   var scale = diff.startAttr.symbolScale;
    //   var end = diff.old ? 1 : (1 + 8 / node.symbol.size.shortestSide);
    //   var tw = ChartDoubleTween(option: getAnimation(LayoutType.update));
    //   tw.addListener(() {
    //     var t = tw.value;
    //     node.symbol.scale = lerpDouble(scale, end, t)!;
    //     node.fillStyle = FillStyle.lerp(diff.startAttr.itemStyle, diff.endAttr.itemStyle, t);
    //     node.sideStyle = SideStyle.lerp(diff.startAttr.borderStyle, diff.endAttr.borderStyle, t);
    //     notifyLayoutUpdate();
    //   });
    //   tl.add(tw);
    // }
    // for (var t in tl) {
    //   t.start(context, true);
    // }
  }


}

