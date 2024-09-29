import 'package:e_chart/e_chart.dart';

///只能按照分组进行布局
class BoxView extends AnimateGeomView<BoxGeom> {
  BoxView(super.context, super.geom);

  @override
  void onLayoutPositionAndSize(List<DataNode> nodeList) {
    var dimX = geom.xPos.axisDim;
    var dimY = geom.yPos.axisDim;
    var coord = geom.findCoord(context);
    if (coord == null) {
      return;
    }
  }

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList) {
    // for (var node in nodeList) {
    //   var xList = node.xList;
    //   var yList = node.yList;
    //   node.extra1 = xList;
    //   node.extra2 = yList;
    //   node.x = (xList.first + xList.last) / 2;
    //   node.y = (yList.first + yList.last) / 2;
    //   node.width = (xList.last - xList.first).abs();
    //   node.height = (yList.last - yList.first).abs();
    //
    //   var p = parent;
    //   if (geom.type == BoxType.boxplot) {
    //     if (p is PolarCoord) {
    //       node.shape = ShapeFactory.buildBoxplotForPolar(p.center, xList, yList);
    //     } else {
    //       node.shape = ShapeFactory.buildBoxplot(xList, yList);
    //     }
    //     return;
    //   }
    //   if (geom.type == BoxType.candlestick) {
    //     if (p is PolarCoord) {
    //       node.shape = ShapeFactory.buildCandlestickForPolar(p.center, xList, yList);
    //     } else {
    //       node.shape = ShapeFactory.buildCandlestick(xList, yList);
    //     }
    //   }
    // }
  }
}
