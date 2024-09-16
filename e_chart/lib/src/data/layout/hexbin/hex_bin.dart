import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'hex.dart';
import 'layout.dart';

///正六边形布局
/// https://www.redblobgames.com/grids/hexagons/implementation.html#rounding
class HexBinTransform extends PointTransform {
  static const double _sqrt3 = 1.7320508; //sqrt(3)
  static const _Orientation _pointy =
      _Orientation(_sqrt3, _sqrt3 / 2.0, 0.0, 3.0 / 2.0, _sqrt3 / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 90);
  static const _Orientation _flat =
      _Orientation(3.0 / 2.0, 0.0, _sqrt3 / 2.0, _sqrt3, 2.0 / 3.0, 0.0, -1.0 / 3.0, _sqrt3 / 3.0, 0);

  HexbinLayout layout;
  Offset center;

  bool flat = false;
  bool ignoreNull;
  double radius = 24;

  ///Hex(0,0,0)的位置
  Offset _zeroCenter = Offset.zero;

  HexBinTransform(
    this.layout, {
    this.radius = 24,
    this.flat = false,
    this.ignoreNull = true,
    this.center = const Offset(0.5, 0.5),
  });

  @override
  void transform(Context context, double width, double height, List<DataNode> nodeList) {
    //initDataIndexAndStyle(newList);
    layoutData(nodeList, width, height);
  }

  void layoutData(List<DataNode> dataList, double width, double height) {
    var params = HexbinLayoutParams(center, width, height, radius.toDouble(), flat);
    var hexLayout = layout;
    hexLayout.onLayout(dataList, LayoutType.layout, params);
    flat = params.flat;

    ///坐标转换
    final angleOffset = flat ? _flat.angle : _pointy.angle;
    _zeroCenter = hexLayout.computeZeroCenter(params);
    final size = Size.square(radius * 1);
    each(dataList, (data, i) {
      var center = hexToPixel(_zeroCenter, data.extra1, size);

      data.center = center;
      data.angleOffset = angleOffset;
      data.r = radius;
      data.scale = 1;
      data.shape = PositiveShape(center: center, angleOffset: angleOffset, r: radius, count: 6);
    });
  }

  ///计算方块中心坐标(center表示Hex(0,0,0)的位置)
  ///将Hex转换为Pixel
  Offset hexToPixel(Offset center, Hex h, Size size) {
    _Orientation M = flat ? _flat : _pointy;
    double x = (M.f0 * h.q + M.f1 * h.r) * size.width;
    double y = (M.f2 * h.q + M.f3 * h.r) * size.height;
    return Offset(x + center.dx, y + center.dy);
  }

  ///将Pixel转为Hex
  Hex pixelToHex(Offset offset) {
    Offset center = _zeroCenter;
    _Orientation M = flat ? _flat : _pointy;
    Point pt = Point((offset.dx - center.dx) / radius, (offset.dy - center.dy) / radius);
    double qt = M.b0 * pt.x + M.b1 * pt.y;
    double rt = M.b2 * pt.x + M.b3 * pt.y;
    double st = -qt - rt;
    return Hex.round(qt, rt, st);
  }

//
// void onHandleHoverAndClickEnd(HexBinData? oldNode, HexBinData? newNode) {
//   oldNode?.drawIndex = 0;
//   newNode?.drawIndex = 100;
//   if (newNode != null) {}
// }

// void onRunUpdateAnimation(var list, var animation) {
//   for (var diff in list) {
//     diff.data.drawIndex = diff.old ? 0 : 100;
//   }
//   sortList(showNodeList);
//
//   List<ChartTween> tl = [];
//   for (var diff in list) {
//     var lerp = ChartDoubleTween(option: animation);
//     var node = diff.data;
//     var startAttr = diff.startAttr;
//     var endAttr = diff.endAttr;
//     lerp.addListener(() {
//       var t = lerp.value;
//       node.fillStyle = FillStyle.lerp(startAttr.itemStyle, endAttr.itemStyle, t);
//       node.sideStyle = SideStyle.lerp(startAttr.borderStyle, endAttr.borderStyle, t);
//       if (diff.old) {
//         node.scale = lerpDouble(startAttr.symbolScale, 1, t)!;
//       } else {
//         node.scale = lerpDouble(startAttr.symbolScale, 1.1, t)!;
//       }
//       notifyLayoutUpdate();
//     });
//     tl.add(lerp);
//     lerp.start(context, true);
//   }
//   each(tl, (p0, p1) {
//     p0.start(context, true);
//   });
// }

// void onDragMove(Offset offset, Offset diff) {
//   views.translationX += diff.dx;
//   views.translationY += diff.dy;
//   var sRect = getViewPortRect().inflate(radius * 2);
//   showNodeList = _rBush.search2(sRect);
//   notifyLayoutUpdate();
// }
//
// HexBinData? findData(Offset offset, [bool overlap = false]) {
//   var rect = Rect.fromCircle(center: offset, radius: radius);
//   var result = _rBush.search2(rect);
//   result.sort((a, b) {
//     return b.drawIndex.compareTo(a.drawIndex);
//   });
//   for (var node in result) {
//     if (node.contains(offset)) {
//       return node;
//     }
//   }
//   return null;
// }
//
// void updateShowNodeList(List<HexBinData> nodeList) {
//   List<HexBinData> nl = [];
//   var sRect = getViewPortRect();
//   each(nodeList, (node, p1) {
//     if (sRect.overlapCircle(node.center, radius)) {
//       nl.add(node);
//     }
//   });
// }
}

class _Orientation {
  final double f0;
  final double f1;
  final double f2;
  final double f3;
  final double b0;
  final double b1;
  final double b2;
  final double b3;
  final double angle;

  const _Orientation(this.f0, this.f1, this.f2, this.f3, this.b0, this.b1, this.b2, this.b3, this.angle);
}
