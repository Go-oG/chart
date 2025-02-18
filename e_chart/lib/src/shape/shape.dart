import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';

//图元Shape
abstract class CShape extends Disposable {
  late final String id;
  int priority;
  double scale = 1;
  double rotation = 0;

  CShape({
    this.priority = 1,
    String? id,
    this.scale = 1,
  }) {
    this.id = isEmpty(id) ? randomId() : id!;
  }

  @nonVirtual
  Path get path {
    var p = _path;
    if (p != null) {
      return p;
    }
    return _path = buildPath();
  }

  Path? _path;

  @nonVirtual
  Rect get bound {
    var box = _bound;
    if (box != null) {
      return box;
    }
    return _bound = buildBound();
  }

  Rect? _bound;

  Path buildPath();

  Rect buildBound() {
    return path.getBounds();
  }

  bool get isClosed;

  bool contains(Offset offset) => bound.contains2(offset) && path.contains(offset);

  ///标记数据为脏数据 需要重新更新 path和bound
  void markDirty() {
    _bound = null;
    _path = null;
  }

  void render(Canvas2 canvas, Paint paint, CStyle style) {
    style.drawPath(canvas, paint, path, bound);
  }

  Attrs pickAttr() {
    Attrs map = Attrs();
    map[Attr.scaleX] = scale;
    map[Attr.scaleY] = scale;
    var size = bound.size;
    map[Attr.width] = size.width;
    map[Attr.height] = size.height;
    map[Attr.rotation] = rotation;
    map[Attr.x] = bound.centerX;
    map[Attr.y] = bound.centerY;
    return map;
  }

  void lerp(Attrs s, Attrs e, double t) {
    //   fill(s.lerp(e, t));
  }

  void fill(Attrs attr);
}

class EmptyShape extends CShape {
  static final EmptyShape none = EmptyShape();
  static final _emptyPath = Path();

  @override
  Path buildPath() {
    return _emptyPath;
  }

  @override
  bool get isClosed => false;

  @override
  void fill(Attrs attr) {}
}
