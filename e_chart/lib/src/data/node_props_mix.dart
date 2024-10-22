import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

Set<Attr> _useAttrSet = <Attr>{
  Attr.x,
  Attr.y,
  Attr.width,
  Attr.height,
  Attr.innerRadius,
  Attr.outRadius,
  Attr.startAngle,
  Attr.sweepAngle,
  Attr.offset,
  Attr.maxRadius,
  Attr.corner,
  Attr.pad,
  Attr.rotation,
  Attr.scale,
  Attr.scaleX,
  Attr.scaleY
};

mixin NodePropsMix {
  final Map<Attr, dynamic> _attrMap = {};
  late int index;

  /// x->dim.col
  /// y-> dim.row
  double get x => _attrMap[Attr.x];

  set x(num v) => _attrMap[Attr.x] = v.toDouble();

  double get y => _attrMap[Attr.y];

  set y(num v) => _attrMap[Attr.y] = v.toDouble();

  double get width => _attrMap[Attr.width];

  set width(num v) => _attrMap[Attr.width] = v.toDouble();

  double get height => _attrMap[Attr.height];

  set height(num v) => _attrMap[Attr.height] = v.toDouble();

  double get angleOffset => _attrMap[Attr.offset] ?? 0;

  set angleOffset(num v) => _attrMap[Attr.offset] = v.toDouble();

  double get cornerRadius => _attrMap[Attr.corner] ?? 0;

  set cornerRadius(num v) => _attrMap[Attr.corner] = v.toDouble();

  //间距的表示,对应圆弧或者极坐标系 它应该是一个角度值
  double get pad => _attrMap[Attr.pad] ?? 0;

  set pad(num v) => _attrMap[Attr.pad] = v.toDouble();

  double get startAngle => _attrMap[Attr.startAngle];

  set startAngle(num v) => _attrMap[Attr.startAngle] = v.toDouble();

  double get sweepAngle => _attrMap[Attr.sweepAngle];

  set sweepAngle(num v) => _attrMap[Attr.sweepAngle] = v.toDouble();

  double get inRadius => _attrMap[Attr.innerRadius];

  set inRadius(num v) => _attrMap[Attr.innerRadius] = v.toDouble();

  double get outRadius => _attrMap[Attr.outRadius];

  set outRadius(num v) => _attrMap[Attr.outRadius] = v.toDouble();

  double? get maxRadius => _attrMap[Attr.maxRadius];

  set maxRadius(num? v) => _attrMap[Attr.maxRadius] = v?.toDouble();

  double get rotate => _attrMap[Attr.rotation] ?? 0;

  set rotate(num v) => _attrMap[Attr.rotation] = v.toDouble();

  double get scale {
    var sx = scaleX;
    var sy = scaleY;
    if (sx == sy) {
      return sx;
    }
    return min(sx, sy);
  }

  set scale(num v) {
    scaleX = v;
    scaleY = v;
  }

  double get scaleX => _attrMap[Attr.scaleX] ?? 1;

  set scaleX(num v) => _attrMap[Attr.scaleX] = v.toDouble();

  double get scaleY => _attrMap[Attr.scaleY] ?? 1;

  set scaleY(num v) => _attrMap[Attr.scaleY] = v.toDouble();

  ///偏移量
  double get offset => _attrMap[Attr.offset] ?? 0;
  set offset(num v) => _attrMap[Attr.offset] = v.toDouble();

  ///下面定义的常用字段在不同的布局中被使用
  late int deep;
  late int maxDeep;
  late int treeHeight;

  ///权重值
  late double weight = 1;

  late double value = double.nan;

  /// 当前X方向速度分量
  late double vx = 0;

  /// 当前Y方向速度分量
  late double vy = 0;

  double get left => x - width / 2;

  double get top => y - height / 2;

  double get right => x + width / 2;

  double get bottom => y + height / 2;

  ///用于某些附加数据(只应该在Chart内部使用)
  dynamic extra1;
  dynamic extra2;
  dynamic extra3;
  dynamic extra4;

  double get r => min(width, height) / 2;

  set r(num v) => width = height = v * 2;

  set size(Size s) {
    width = s.width;
    height = s.height;
  }

  Size get size => Size(width, height);

  Offset get center => Offset(x, y);

  set center(Offset ce) {
    x = ce.dx;
    y = ce.dy;
  }

  Rect get position => Rect.fromCenter(center: center, width: width, height: height);

  set position(Rect rect) {
    Offset center = rect.center;
    x = center.dx;
    y = center.dy;
    size = rect.size;
  }

  void fillFromAttr(Attrs attr) {
    for (var entry in attr.attrs.entries) {
      var key = entry.key;
      if (!_useAttrSet.contains(key)) {
        continue;
      }
      var v = entry.value;
      if (key == Attr.maxRadius && v is num?) {
        _attrMap[key] = v;
        continue;
      }
      if (v is! num) {
        throw ChartError("违法参数:key:$key value:$v");
      }
      _attrMap[key] = v.toDouble();
    }
  }

  Attrs pickArc() {
    Attrs map = pickXY();
    map[Attr.innerRadius] = inRadius;
    map[Attr.outRadius] = outRadius;
    map[Attr.startAngle] = startAngle;
    map[Attr.sweepAngle] = sweepAngle;
    map[Attr.corner] = cornerRadius;
    map[Attr.pad] = pad;
    map[Attr.maxRadius] = maxRadius;
    return map;
  }

  Attrs pickXY() {
    return Attrs({Attr.x: x, Attr.y: y});
  }

  Attrs pickAttr(Iterable<Attr> fields) {
    Attrs map = Attrs();
    for (var field in fields) {
      if (!_useAttrSet.contains(field)) {
        throw ChartError("违法字段名");
      }
      map[field] = _attrMap[field];
    }
    return map;
  }

  Arc buildArcShape() {
    return Arc(
        center: Offset(x, y),
        outRadius: outRadius,
        innerRadius: inRadius,
        sweepAngle: sweepAngle,
        startAngle: startAngle,
        cornerRadius: cornerRadius,
        padAngle: pad,
        maxRadius: maxRadius);
  }

  void printShapeAttr() {
    var build = StringBuffer();
    for (var attr in _useAttrSet) {
      var v = _attrMap[attr];
      build.write("$attr:$v");
      build.write(",");
    }
    Logger.i("Attr:$build");
  }
}
