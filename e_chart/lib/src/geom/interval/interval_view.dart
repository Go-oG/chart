import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class IntervalView extends GeomView<IntervalGeom> {
  IntervalView(super.context, super.series);

  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    setMeasuredDimension(widthSpec.size, heightSpec.size);
  }

  @override
  void onLayoutPositionAndSize(List<DataNode> nodeList) {
    var xDim = geom.xPos.toAxisDim();
    var yDim = geom.yPos.toAxisDim();
    var cord = parent as CoordView;
    // for (var node in nodeList) {
    //   List<Offset> ol = [];
    //   for (var co in node.controlPoint) {
    //     ol.add(Offset(cord.convert(xDim, co.dx), cord.convert(yDim, co.dy)));
    //   }
    //   node.controlPoint = ol;
    // }
  }

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList, bool isIntercept) {
    if (isIntercept) {
      return;
    }
    // for (var node in nodeList) {
    //   Path path = Path();
    //   each(node.controlPoint, (p0, p1) {
    //     if (p1 == 0) {
    //       path.moveTo2(p0);
    //     } else {
    //       path.lineTo2(p0);
    //     }
    //   });
    //   path.close();
    //   node.shape = PathShape(path);
    // }
  }
}
