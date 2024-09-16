import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class BoxGeom extends Geom {
  //分组比例
  BoxType type;
  List<double>? groupRatio;
  double padding;
  double gap;

  BoxGeom(
    super.dataSet,
    super.scope, {
    this.type = BoxType.boxplot,
    this.padding = 0.01,
    this.gap = 0.01,
    this.groupRatio,
  });

  @override
  ChartView? toView(Context context) {
    return BoxView(context, this);
  }

  @override
  GeomType get geomType => GeomType.box;


  // void normalizeData(Context context, List<DataNode> list) {
  //   var xScale = context.dataManager.getAxisScale(coordId, xPos.toAxisDim());
  //   var yScale = context.dataManager.getAxisScale(coordId, yPos.toAxisDim());
  //   for (var node in list) {
  //     List<double> xList = [];
  //     List<double> yList = [];
  //     for (var entry in node.posDataMap.entries) {
  //       var scale = entry.key.isX ? xScale : yScale;
  //       var list = entry.key.isX ? xList : yList;
  //       for (var part in entry.value) {
  //         var raw = part.raw;
  //         if (raw == null) {
  //           part.ratio = double.nan;
  //           continue;
  //         }
  //         part.ratio = scale.normalize(raw);
  //         list.add(part.ratio);
  //       }
  //     }
  //
  //     var band = xScale.bandRatio;
  //     var x = xList.first;
  //     xList.insert(0, x - band / 2);
  //     xList.add(x + band / 2);
  //     List<Offset> ol = [];
  //
  //     for (var y in yList) {
  //       for (var xv in xList) {
  //         ol.add(Offset(xv, y));
  //       }
  //     }
  //
  //     node.controlPoint = ol;
  //   }
  // }

}

enum BoxType {
  boxplot,
  candlestick,
}
