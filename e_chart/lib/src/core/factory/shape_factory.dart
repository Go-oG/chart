import 'dart:ui';

import 'package:e_chart/e_chart.dart';

typedef ShapeBuilder = CShape? Function(LayoutResult value, Size size, Attrs attrs);

final shapeFactory = ShapeFactory._();

final class ShapeFactory {
  final Map<ShapeType, ShapeBuilder> _builderMap = {};

  ShapeFactory._() {
    addBuilder(ShapeType.circle, circleShapeBuilder);
    addBuilder(ShapeType.prism, prismShapeBuilder);
  }

  void addBuilder(ShapeType type, ShapeBuilder builder) {
    _builderMap[type] = builder;
  }

  void removeBuilder(ShapeType type) {
    _builderMap.remove(type);
  }

  static PathShape buildBoxplot(List<double> xList, List<double> yList) {
    var vertical = yList.length >= xList.length;

    final pList = vertical ? yList : xList;
    final tList = vertical ? xList : yList;
    checkArgs(pList.length == 5 || pList.length == 6);
    var centerX = (tList.first + tList.last) / 2;

    Offset low = Offset(centerX, pList[0]);
    Offset low1 = Offset(tList[0], pList[0]);
    Offset low2 = Offset(tList[1], pList[0]);

    Offset low4 = Offset(centerX, pList[1]);
    Offset low41 = Offset(tList[0], pList[1]);
    Offset low42 = Offset(tList[1], pList[1]);

    Offset medium1 = Offset(centerX, pList[2]);
    Offset medium2 = Offset(tList[1], pList[2]);

    Offset up4 = Offset(centerX, pList[3]);
    Offset up41 = Offset(tList[0], pList[3]);
    Offset up42 = Offset(tList[1], pList[3]);

    Offset up = Offset(centerX, pList[4]);
    Offset up1 = Offset(tList[0], pList[4]);
    Offset up2 = Offset(tList[1], pList[4]);

    Path path = Path();
    vertical ? path.moveTo2(low1) : path.moveTo(low1.dy, low1.dx);
    vertical ? path.lineTo2(low2) : path.lineTo(low2.dy, low2.dx);

    vertical ? path.moveTo2(low) : path.moveTo(low.dy, low.dx);
    vertical ? path.lineTo2(low4) : path.lineTo(low4.dy, low4.dx);

    vertical ? path.moveTo2(low41) : path.moveTo(low41.dy, low41.dx);
    vertical ? path.lineTo2(up41) : path.lineTo(up41.dy, up41.dx);
    vertical ? path.lineTo2(up42) : path.lineTo(up42.dy, up42.dx);
    vertical ? path.lineTo2(low42) : path.lineTo(low42.dy, low42.dx);
    vertical ? path.lineTo2(low41) : path.lineTo(low41.dy, low41.dx);

    vertical ? path.moveTo2(medium1) : path.moveTo(medium1.dy, medium1.dx);
    vertical ? path.lineTo2(medium2) : path.lineTo(medium2.dy, medium2.dx);

    vertical ? path.moveTo2(up4) : path.moveTo(up4.dy, up4.dx);
    vertical ? path.lineTo2(up) : path.lineTo(up.dy, up.dx);

    vertical ? path.moveTo2(up1) : path.moveTo(up1.dy, up1.dx);
    vertical ? path.lineTo2(up2) : path.lineTo(up2.dy, up2.dx);

    Path p2 = Path();
    vertical ? p2.moveTo2(low41) : p2.moveTo(low41.dy, low41.dx);
    vertical ? p2.lineTo2(up41) : p2.lineTo(up41.dy, up41.dx);
    vertical ? p2.lineTo2(up42) : p2.lineTo(up42.dy, up42.dx);
    vertical ? p2.lineTo2(low42) : p2.lineTo(low42.dy, low42.dx);
    vertical ? p2.lineTo2(low41) : p2.lineTo(low41.dy, low41.dx);
    p2.close();
    path.addPath(p2, Offset.zero);
    return PathShape(path);
  }

  static PathShape buildBoxplotForPolar(Offset center, List<double> xList, List<double> yList) {
    final vertical = yList.length > xList.length;
    var pList = vertical ? yList : xList;
    checkArgs(pList.length == 5 || pList.length == 6);

    var centerAngle = (xList.first + xList.last) / 2;
    var startAngle = xList.first;
    var endAngle = xList.last;

    Offset low, low1, low2;
    Offset low4, low41, low42;
    Offset medium1, medium2;
    Offset up4, up41, up42;
    Offset up, up1, up2;

    if (vertical) {
      low = circlePoint(yList[0], centerAngle, center);
      low1 = circlePoint(yList[0], startAngle, center);
      low2 = circlePoint(yList[0], endAngle, center);

      low4 = circlePoint(yList[1], centerAngle, center);
      low41 = circlePoint(yList[1], startAngle, center);
      low42 = circlePoint(yList[1], endAngle, center);

      medium1 = circlePoint(yList[2], startAngle, center);
      medium2 = circlePoint(yList[2], endAngle, center);

      up4 = circlePoint(yList[3], centerAngle, center);
      up41 = circlePoint(yList[3], startAngle, center);
      up42 = circlePoint(yList[3], endAngle, center);

      up = circlePoint(yList[4], centerAngle, center);
      up1 = circlePoint(yList[4], startAngle, center);
      up2 = circlePoint(yList[4], endAngle, center);
    } else {
      var cr = (yList.first + yList.last) / 2;
      var sr = yList.first;
      var er = yList.last;
      low = circlePoint(cr, xList[0], center);
      low1 = circlePoint(sr, xList[0], center);
      low2 = circlePoint(er, xList[0], center);

      low4 = circlePoint(cr, xList[1], center);
      low41 = circlePoint(sr, xList[1], center);
      low42 = circlePoint(er, xList[1], center);

      medium1 = circlePoint(sr, xList[2], center);
      medium2 = circlePoint(er, xList[2], center);

      up4 = circlePoint(cr, xList[3], center);
      up41 = circlePoint(sr, xList[3], center);
      up42 = circlePoint(er, xList[3], center);

      up = circlePoint(cr, xList[4], center);
      up1 = circlePoint(sr, xList[4], center);
      up2 = circlePoint(er, xList[4], center);
    }

    Path path = Path();
    path.moveTo2(low1);
    path.lineTo2(low2);

    path.moveTo2(low);
    path.lineTo2(low4);

    path.moveTo2(low41);
    path.lineTo2(up41);
    path.lineTo2(up42);
    path.lineTo2(low42);
    path.lineTo2(low41);

    path.moveTo2(medium1);
    path.lineTo2(medium2);

    path.moveTo2(up4);
    path.lineTo2(up);

    path.moveTo2(up1);
    path.moveTo2(up2);

    Path p2 = Path();
    p2.moveTo2(low41);
    p2.lineTo2(up41);
    p2.lineTo2(up42);
    p2.lineTo2(low42);
    p2.close();

    path.addPath(p2, Offset.zero);
    return PathShape(path);
  }

  static PathShape buildCandlestick(List<double> xList, List<double> yList) {
    var vertical = yList.length >= xList.length;

    final pList = vertical ? yList : xList;
    final tList = vertical ? xList : yList;
    checkArgs(pList.length == 4);
    var centerX = (tList.first + tList.last) / 2;

    Offset low = Offset(centerX, pList[0]);
    Offset up = Offset(centerX, pList[2]);

    Offset open = Offset(centerX, pList[1]);
    Offset open1 = Offset(tList[0], pList[1]);
    Offset open2 = Offset(tList[1], pList[1]);

    Offset close = Offset(centerX, pList[2]);
    Offset close1 = Offset(tList[0], pList[2]);
    Offset close2 = Offset(tList[1], pList[2]);

    Path path = Path();
    vertical ? path.moveTo2(low) : path.moveTo(low.dy, low.dx);
    if (pList[1] >= pList[2]) {
      vertical ? path.lineTo2(close) : path.lineTo(close.dy, close.dx);

      vertical ? path.moveTo2(open) : path.moveTo(open.dy, open.dx);
      vertical ? path.lineTo2(up) : path.lineTo(up.dy, up.dx);
    } else {
      vertical ? path.lineTo2(open) : path.lineTo(open.dy, open.dx);
      vertical ? path.moveTo2(close) : path.moveTo(close.dy, close.dx);
      vertical ? path.lineTo2(up) : path.lineTo(up.dy, up.dx);
    }

    Path p2 = Path();
    p2.moveTo2(close1);
    p2.lineTo2(open1);
    p2.lineTo2(open2);
    p2.lineTo2(close2);
    p2.close();
    path.addPath(p2, Offset.zero);

    return PathShape(path);
  }

  static PathShape buildCandlestickForPolar(Offset center, List<double> xList, List<double> yList) {
    return PathShape(Path());
  }
}
