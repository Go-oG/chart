import 'dart:math';
import 'dart:ui';

mixin AttrMixin {
  final Map<String, dynamic> _attrs = {};

  int index = 0;

  double get x => _attrs[Attr.x];

  set x(num v) => _attrs[Attr.x] = v.toDouble();

  double get y => _attrs[Attr.y];

  set y(num v) => _attrs[Attr.y] = v.toDouble();

  double get width => getAttr(Attr.width, 0);

  set width(num v) => setAttr(Attr.width, v.toDouble());

  double get height => getAttr(Attr.height, 0);

  set height(num v) => setAttr(Attr.height, v.toDouble());

  double get left => x - width / 2;

  double get top => y - height / 2;

  double get right => x + width / 2;

  double get bottom => y + height / 2;

  double get rotate => getAttr(Attr.rotation, 0);

  set rotate(num v) => setAttr(Attr.rotation, v.toDouble());

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

  double get scaleX => _attrs[Attr.scaleX] ?? 1;

  set scaleX(num v) => _attrs[Attr.scaleX] = v.toDouble();

  double get scaleY => _attrs[Attr.scaleY] ?? 1;

  set scaleY(num v) => _attrs[Attr.scaleY] = v.toDouble();

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

  int get deep => getAttr(Attr.deep);

  set deep(int v) => setAttr(Attr.deep, v);

  int get maxDeep => getAttr(Attr.maxDeep);

  set maxDeep(int v) => setAttr(Attr.maxDeep, v);

  int get treeHeight => getAttr(Attr.treeHeight);

  set treeHeight(int v) => setAttr(Attr.treeHeight, v);

  double get weight => getAttr(Attr.weight, 1);

  set weight(num v) => setAttr(Attr.weight, v.toDouble());

  double get r => min(width, height) / 2;

  set r(num v) {
    width = height = v * 2.0;
  }

  double get angleOffset => getAttr(Attr.angleOffset, 0);

  set angleOffset(num v) => getAttr(Attr.angleOffset, v.toDouble());

  double get cornerRadius => getAttr(Attr.corner, 0) ?? 0;

  set cornerRadius(num v) => setAttr(Attr.corner, v.toDouble());

  //间距的表示,对应圆弧或者极坐标系 它应该是一个角度值
  double get pad => getAttr(Attr.pad, 0);

  set pad(num v) => setAttr(Attr.pad, v.toDouble());

  double get startAngle => getAttr(Attr.startAngle, 0);

  set startAngle(num v) => setAttr(Attr.startAngle, v.toDouble());

  double get sweepAngle => getAttr(Attr.sweepAngle, 0);

  set sweepAngle(num v) => setAttr(Attr.sweepAngle, v.toDouble());

  double get inRadius => getAttr(Attr.innerRadius, 0);

  set inRadius(num v) => setAttr(Attr.innerRadius, v.toDouble());

  double get outRadius => getAttr(Attr.outRadius, 0);

  set outRadius(num v) => setAttr(Attr.outRadius, v.toDouble());

  double? get maxRadius => getAttr(Attr.maxRadius, 0);

  set maxRadius(num? v) => setAttr(Attr.maxRadius, v?.toDouble());

  ///偏移量
  double get offset => getAttr(Attr.offset, 0);

  set offset(num v) => setAttr(Attr.offset, v.toDouble());

  late double value = double.nan;

  /// 当前X方向速度分量
  late double vx = 0;

  /// 当前Y方向速度分量
  late double vy = 0;

  Rect get position => Rect.fromCenter(center: center, width: width, height: height);

  set position(Rect rect) {
    Offset center = rect.center;
    x = center.dx;
    y = center.dy;
    size = rect.size;
  }

  ///固定的值访问
  double? get fx => getAttr(Attr.fx);

  double? get fy => getAttr(Attr.fy);

  double? get fixValue => getAttr(Attr.fixValue);

  ///用于某些附加数据(只应该在Chart内部使用)
  dynamic extra1;
  dynamic extra2;
  dynamic extra3;
  dynamic extra4;

  void setAttr(String attr, dynamic value) {
    _attrs[attr] = value;
  }

  T getAttr<T>(String attr, [T? defaultValue]) {
    return _attrs[attr] ?? defaultValue;
  }

  T? getAttr2<T>(String attr) {
    return _attrs[attr] as T?;
  }

  Map<String, dynamic> get attrs => _attrs;
}

final class Attr {
  Attr._();

  static const x = ("x");
  static const y = ("y");
  static const width = ("width");
  static const height = ("height");
  static const maxWidth = ("maxWidth");
  static const maxHeight = ("maxHeight");

  static const innerRadius = ("innerRadius");
  static const outRadius = ("outRadius");
  static const startAngle = ("startAngle");
  static const sweepAngle = ("sweepAngle");
  static const maxRadius = ("maxRadius");

  static const corner = ("corner");
  static const leftTopCorner = ("leftTopCorner");
  static const rightTopCorner = ("rightTopCorner");
  static const leftBottomCorner = ("leftBottomCorner");
  static const rightBottomCorner = ("rightBottomCorner");

  static const pad = ("pad");

  static const color = ("color");
  static const alpha = ("alpha");
  static const smooth = ("smooth");

  static const dash = ("dash");
  static const scale = ("scale");
  static const scaleX = ("scaleX");
  static const scaleY = ("scaleY");

  static const rotation = ("rotation");

  static const offset = ("offset");
  static const center = ("center");
  static const angleOffset = ("angleOffset");
  static const inside = ("inside");
  static const count = ("count");
  static const deep = ("deep");
  static const maxDeep = ("maxDeep");
  static const treeHeight = ("treeHeight");
  static const weight = ("weight");

  static const value = ("value");
  static const fx = ("fx");
  static const fy = ("fy");
  static const fixWidth = ("fixWidth");
  static const fixHeight = ("fixHeight");
  static const fixValue = ("fixValue");

  static const extra1 = ("extra1");
  static const extra2 = ("extra2");
  static const extra3 = ("extra3");
  static const extra4 = ("extra4");
}

typedef Attrs = Map<String, dynamic>;
