import 'package:e_chart/e_chart.dart';

class IntervalGeom extends Geom {
  IntervalGeom(super.dataSet, super.scope);

  @override
  ChartView? toView(Context context) {
    return IntervalView(context, this);
  }

  @override
  GeomType get geomType => GeomType.interval;

  // void normalizeData(Context context, List<DataNode> list) {
  //   var xScale = context.dataManager.getAxisScale(coordId, xPos.toAxisDim());
  //   var yScale = context.dataManager.getAxisScale(coordId, yPos.toAxisDim());
  //   var xBand = xScale.bandRatio;
  //   var yBand = yScale.bandRatio;
  //   Logger.i("xB:${xBand} yB:${yBand}");
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
  //     if (xList.length < 2) {
  //       var x = xList.first;
  //       xList = [x - xBand / 2, x + xBand / 2];
  //     }
  //     if (yList.length < 2) {
  //       var y = yList.first;
  //       yList = [y - yBand / 2, y + yBand / 2];
  //     }
  //
  //     node.controlPoint = [
  //       Offset(xList[0], yList[1]),
  //       Offset(xList[0], yList[0]),
  //       Offset(xList[1], yList[0]),
  //       Offset(xList[1], yList[1]),
  //     ];
  //     Logger.i('归一化结果:${node.controlPoint}');
  //   }
  // }

}
