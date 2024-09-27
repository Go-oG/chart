import 'dart:math';
import 'dart:ui';

import '../model/helper/lerp.dart';

final class Attrs {
  static final Attrs empty = Attrs();

  final Map<Attr, dynamic> _attrs = {};

  Map<Attr, dynamic> get attrs => _attrs;

  Attrs([Map<Attr, dynamic>? attrs]) {
    if (attrs != null) {
      addAll(attrs);
    }
  }

  void add(Attr attr, dynamic value) {
    _attrs[attr] = value;
  }

  void addAll(Map<Attr, dynamic> attrs) {
    _attrs.addAll(attrs);
  }

  void remove(Attr? attr) {
    _attrs.remove(attr);
  }

  void clear() {
    _attrs.clear();
  }

  Attrs copy() {
    return Attrs(_attrs);
  }

  dynamic operator [](Attr attr) {
    return _attrs[attr];
  }

  void operator []=(Attr attr, dynamic value) {
    _attrs[attr] = value;
  }

  Offset? getCenter([Offset? defaultValue]) {

    return getOffset() ?? defaultValue;
  }


  Offset? getOffset() {
    var data = getList([Attr.x, Attr.y]);
    if (data.first is num && data.last is num) {
      return Offset((data.first as num).toDouble(), (data.last as num).toDouble());
    }
    return null;
  }

  Size? getSize([Size? defaultValue = Size.zero]) {
    var w = getNum([Attr.width], -1);
    var h = getNum([Attr.height], -1);
    if (w >= 0 && h >= 0) {
      return Size(w.toDouble(), h.toDouble());
    }
    var radius = getNum([Attr.outRadius], -1);
    if (radius >= 0) {
      return Size.square(radius * 2.0);
    }
    radius = getNum([Attr.innerRadius], -1);
    if (radius >= 0) {
      return Size.square(radius * 2.0);
    }
    return defaultValue;
  }

  double? getRadius([num defaultValue = 0]) {
    var radius = getNum([Attr.outRadius], -1);
    if (radius >= 0) {
      return radius.toDouble();
    }

    var size = getSize();

    if (size == null) {
      return defaultValue.toDouble();
    }
    return min(size.width, size.height) / 2;
  }

  num getNum(List<Attr> fields, [num defaultValue = 0]) {
    var data = getObject(fields);
    if (data is num) {
      return data;
    }
    if (data is List<num> && data.length == 1) {
      return data.first;
    }
    return defaultValue;
  }

  int getInt(List<Attr> fields, [int defaultValue = 0]) {
    return getNum(fields, defaultValue).toInt();
  }

  double getDouble(List<Attr> fields, [double defaultValue = 0]) {
    return getNum(fields, defaultValue).toDouble();
  }

  dynamic getObject(List<Attr> fields) {
    for (var item in fields) {
      var data = _attrs[item];
      if (data != null) {
        return data;
      }
    }
  }

  List<dynamic> getList(List<Attr> fields) {
    List<dynamic> result = [];
    for (var item in fields) {
      var data = _attrs[item];
      result.add(data);
    }
    return result;
  }

  Attrs lerp(Attrs e, double t) {
    Attrs map = Attrs();
    Set<Attr> keys = <Attr>{};
    keys.addAll(attrs.keys);
    keys.addAll(e.attrs.keys);
    for (var key in keys) {
      var sv = this[key];
      var ev = e[key];
      map[key] = lerpDynamic(sv, ev, t);
    }
    return map;
  }
}

final class Attr {
  final String name;

  const Attr(this.name);

  @override
  bool operator ==(Object other) {
    return other is Attr && other.name == name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }

  static const Attr x = Attr("x");
  static const Attr y = Attr("y");
  static const Attr width = Attr("width");
  static const Attr height = Attr("height");
  static const Attr maxWidth = Attr("maxWidth");
  static const Attr maxHeight = Attr("maxHeight");

  static const Attr innerRadius = Attr("innerRadius");
  static const Attr outRadius = Attr("outRadius");
  static const Attr startAngle = Attr("startAngle");
  static const Attr sweepAngle = Attr("sweepAngle");
  static const Attr maxRadius = Attr("maxRadius");

  static const Attr corner = Attr("corner");
  static const Attr leftTopCorner = Attr("leftTopCorner");
  static const Attr rightTopCorner = Attr("rightTopCorner");
  static const Attr leftBottomCorner = Attr("leftBottomCorner");
  static const Attr rightBottomCorner = Attr("rightBottomCorner");

  static const Attr pad = Attr("pad");

  static const Attr color = Attr("color");
  static const Attr alpha = Attr("alpha");
  static const Attr opacity = Attr("opacity");
  static const Attr smooth = Attr("smooth");

  static const Attr dash = Attr("dash");
  static const Attr scale = Attr("scale");
  static const Attr scaleX = Attr("scaleX");
  static const Attr scaleY = Attr("scaleY");

  static const Attr rotation = Attr("rotation");

  static const Attr offset = Attr("offset");
  static const Attr center = Attr("center");
  static const Attr angleOffset = Attr("angleOffset");
  static const Attr inside = Attr("inside");
  static const Attr count = Attr("count");

  ///其它使用
  ///固定的位置
  static const Attr fx = Attr("fx");
  static const Attr fy = Attr("fy");
  static const Attr fixWidth = Attr("fixWidth");
  static const Attr fixHeight = Attr("fixHeight");
  static const Attr fixValue = Attr("fixValue");
}

enum AttrType {
  string,
  ints,
  doubles,
  boolean,
  object;
}
