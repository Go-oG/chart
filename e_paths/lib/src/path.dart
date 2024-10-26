import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'cubic.dart';

final class Path {
  late final ui.Path _path;

  ui.Path get rawPath => _path;

  final List<PathOperation> _list = [];

  Path() {
    _path = ui.Path();
  }

  Path._(ui.Path p) {
    _path = p;
  }

  PathFillType get fillType => _path.fillType;

  set fillType(PathFillType value) {
    _list.add(PathFillTypeOperation(_list.length, value));
    _path.fillType = value;
  }

  void moveTo(double x, double y) {
    _list.add(MoveOperation(_list.length, false, x, y));
    _path.moveTo(x, y);
  }

  void relativeMoveTo(double dx, double dy) {
    _list.add(MoveOperation(_list.length, true, dx, dy));
    _path.relativeMoveTo(dx, dy);
  }

  void lineTo(double x, double y) {
    _list.add(LineOperation(_list.length, false, x, y));
    _path.lineTo(x, y);
  }

  void relativeLineTo(double dx, double dy) {
    _list.add(LineOperation(_list.length, true, dx, dy));
    _path.relativeLineTo(dx, dy);
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _list.add(QuadraticBezierOperation(_list.length, false, x1, y1, x2, y2));
    _path.quadraticBezierTo(x1, y1, x2, y2);
  }

  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    _list.add(QuadraticBezierOperation(_list.length, true, x1, y1, x2, y2));
    _path.relativeQuadraticBezierTo(x1, y1, x2, y2);
  }

  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    _list.add(CubicOperation(_list.length, false, x1, y1, x2, y2, x3, y3));
    _path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  void relativeCubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    _list.add(CubicOperation(_list.length, true, x1, y1, x2, y2, x3, y3));
    _path.relativeCubicTo(x1, y1, x2, y2, x3, y3);
  }

  void conicTo(double x1, double y1, double x2, double y2, double w) {
    _list.add(ConicOperation(_list.length, false, x1, y1, x2, y2, w));
    _path.conicTo(x1, y1, x2, y2, w);
  }

  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    _list.add(ConicOperation(_list.length, true, x1, y1, x2, y2, w));
    _path.relativeConicTo(x1, y1, x2, y2, w);
  }

  void arcTo(Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    _list.add(ArcToOperation(_list.length, rect, startAngle, sweepAngle, forceMoveTo));
    _path.arcTo(rect, startAngle, sweepAngle, forceMoveTo);
  }

  void arcToPoint(
    Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    _list.add(ArcToPointOperation(_list.length, false, arcEnd, radius, rotation, largeArc, clockwise));
    _path.arcToPoint(arcEnd, radius: radius, rotation: rotation, largeArc: largeArc, clockwise: clockwise);
  }

  void relativeArcToPoint(
    Offset arcEndDelta, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    _list.add(ArcToPointOperation(_list.length, true, arcEndDelta, radius, rotation, largeArc, clockwise));
    _path.relativeArcToPoint(
      arcEndDelta,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  void addRect(Rect rect) {
    _list.add(RectOperation(_list.length, rect));
    _path.addRect(rect);
  }

  void addOval(Rect oval) {
    _list.add(OvalOperation(_list.length, oval));
    _path.addOval(oval);
  }

  void addArc(Rect oval, double startAngle, double sweepAngle) {
    _list.add(ArcOperation(_list.length, oval, startAngle, sweepAngle));
    _path.addArc(oval, startAngle, sweepAngle);
  }

  void addPolygon(List<Offset> points, bool close) {
    _list.add(PolygonOperation(_list.length, points, close));
    _path.addPolygon(points, close);
  }

  void addRRect(RRect rrect) {
    _list.add(RRectOperation(_list.length, rrect));
    _path.addRRect(rrect);
  }

  void addPath(ui.Path path, Offset offset, {Float64List? matrix4}) {
    _list.add(PathPathOperation(_list.length, path, offset, matrix4));
    _path.addPath(path, offset, matrix4: matrix4);
  }

  void extendWithPath(ui.Path path, Offset offset, {Float64List? matrix4}) {
    _list.add(ExtendPathOperation(_list.length, path, offset, matrix4));
    _path.extendWithPath(path, offset, matrix4: matrix4);
  }

  void close() {
    _list.add(ClosePathOperation(
      _list.length,
    ));
    _path.close();
  }

  void reset() {
    _list.clear();
    _path.reset();
  }

  bool contains(Offset point) => _path.contains(point);

  Path shift(Offset offset) {
    List<PathOperation> list = List.from(_list);
    list.add(ShiftOperation(_list.length, offset));

    var path = _path.shift(offset);
    var result = Path._(path);
    result._list.addAll(list);
    return result;
  }

  Path transform(Float64List matrix4) {
    List<PathOperation> list = List.from(_list);
    list.add(TransformPathOperation(_list.length, matrix4));
    var path = _path.transform(matrix4);
    var result = Path._(path);
    result._list.addAll(list);
    return result;
  }

  Rect getBounds() => _path.getBounds();
}

abstract class PathOperation {
  final int index;
  final bool relative;

  const PathOperation(this.index, this.relative);

  ui.Path reappear(ui.Path path);

  PathType get type;

  bool get isCloseEffect;

  List<Cubic>? pickPivot(Path path);

  ui.Offset? pickEndPosition(Path path);

  ui.Offset? pickPreLastPosition(Path path) {
    ui.Offset? end;
    for (int i = index - 1; i >= 0; i--) {
      end = path._list[i].pickEndPosition(path);
      if (end != null) {
        break;
      }
    }
    return end;
  }
}

abstract class UnEffectPathOperation extends PathOperation {
  const UnEffectPathOperation(super.index, super.relative);

  @override
  bool get isCloseEffect => false;

  @override
  List<Cubic>? pickPivot(Path path) => null;
}

class MoveOperation extends PathOperation {
  final double x;
  final double y;

  const MoveOperation(super.index, super.relative, this.x, this.y);

  @override
  ui.Path reappear(ui.Path path) {
    relative ? path.relativeMoveTo(x, y) : path.moveTo(x, y);
    return path;
  }

  @override
  PathType get type => PathType.move;

  @override
  bool get isCloseEffect => false;

  @override
  List<Cubic>? pickPivot(Path path) => null;

  @override
  ui.Offset? pickEndPosition(Path path) {
    if (!relative) {
      return ui.Offset(x, y);
    }
    ui.Offset? end = pickPreLastPosition(path);
    end ??= ui.Offset.zero;
    return ui.Offset(x, y) + end;
  }
}

class LineOperation extends PathOperation {
  final double x;
  final double y;

  const LineOperation(super.index, super.relative, this.x, this.y);

  @override
  ui.Path reappear(ui.Path path) {
    relative ? path.relativeLineTo(x, y) : path.lineTo(x, y);
    return path;
  }

  @override
  PathType get type => PathType.line;

  @override
  bool get isCloseEffect => false;

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    if (!relative) {
      return ui.Offset(x, y);
    }
    ui.Offset? end = pickPreLastPosition(path);
    end ??= ui.Offset.zero;
    return ui.Offset(x, y) + end;
  }
}

class QuadraticBezierOperation extends PathOperation {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const QuadraticBezierOperation(super.index, super.relative, this.x1, this.y1, this.x2, this.y2);

  @override
  ui.Path reappear(ui.Path path) {
    relative ? path.relativeQuadraticBezierTo(x1, y1, x2, y2) : path.quadraticBezierTo(x1, y1, x2, y2);
    return path;
  }

  @override
  PathType get type => PathType.quadraticBezier;

  @override
  bool get isCloseEffect => false;

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    if (!relative) {
      return ui.Offset(x2, y2);
    }
    ui.Offset? end = pickPreLastPosition(path);
    end ??= ui.Offset.zero;
    return ui.Offset(x2, y2) + end;
  }
}

class CubicOperation extends PathOperation {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  final double x3;
  final double y3;

  const CubicOperation(super.index, super.relative, this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);

  @override
  ui.Path reappear(ui.Path path) {
    relative ? path.relativeCubicTo(x1, y1, x2, y2, x3, y3) : path.cubicTo(x1, y1, x2, y2, x3, y3);
    return path;
  }

  @override
  PathType get type => PathType.cubic;

  @override
  bool get isCloseEffect => false;

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    if (!relative) {
      return ui.Offset(x3, y3);
    }

    ui.Offset? end = pickPreLastPosition(path);
    end ??= ui.Offset.zero;
    return ui.Offset(x3, y3) + end;
  }
}

class ConicOperation extends PathOperation {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  final double w;

  const ConicOperation(super.index, super.relative, this.x1, this.y1, this.x2, this.y2, this.w);

  @override
  ui.Path reappear(ui.Path path) {
    relative ? path.relativeConicTo(x1, y1, x2, y2, w) : path.conicTo(x1, y1, x2, y2, w);
    return path;
  }

  @override
  PathType get type => PathType.conic;

  @override
  bool get isCloseEffect => false;

  @override
  List<Cubic>? pickPivot(Path path) {
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    if (!relative) {
      return ui.Offset(x2, y2);
    }
    ui.Offset? end = pickPreLastPosition(path);
    end ??= ui.Offset.zero;
    return ui.Offset(x2, y2) + end;
  }
}

class ArcToOperation extends PathOperation {
  final Rect rect;
  final double startAngle;
  final double sweepAngle;
  final bool forceMoveTo;

  const ArcToOperation(int index, this.rect, this.startAngle, this.sweepAngle, this.forceMoveTo) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.arcTo(rect, startAngle, sweepAngle, forceMoveTo);
    return path;
  }

  @override
  PathType get type => PathType.arcTo;

  @override
  bool get isCloseEffect => false;

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    var angle = (startAngle + sweepAngle) * pi / 180;
    var center = rect.center;
    return ui.Offset(center.dx + cos(angle) * rect.width, center.dy + sin(angle) * rect.height);
  }
}

class ArcToPointOperation extends PathOperation {
  final Offset arcEnd;
  final Radius radius;
  final double rotation;
  final bool largeArc;
  final bool clockwise;

  const ArcToPointOperation(
      super.index, super.relative, this.arcEnd, this.radius, this.rotation, this.largeArc, this.clockwise);

  @override
  ui.Path reappear(ui.Path path) {
    if (relative) {
      path.relativeArcToPoint(arcEnd, radius: radius, rotation: rotation, largeArc: largeArc, clockwise: clockwise);
    } else {
      path.arcToPoint(arcEnd, radius: radius, rotation: rotation, largeArc: largeArc, clockwise: clockwise);
    }
    return path;
  }

  @override
  PathType get type => PathType.arcToPoint;

  @override
  // TODO: implement isCloseEffect
  bool get isCloseEffect => throw UnimplementedError();

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    if (!relative) {
      return arcEnd;
    }
    ui.Offset? end = pickPreLastPosition(path);
    end ??= ui.Offset.zero;
    return arcEnd + end;
  }
}

class RectOperation extends PathOperation {
  final Rect rect;

  const RectOperation(int index, this.rect) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addRect(rect);
    return path;
  }

  @override
  PathType get type => PathType.addRect;

  @override
  bool get isCloseEffect => true;

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    return rect.bottomLeft;
  }
}

class OvalOperation extends PathOperation {
  final Rect oval;

  const OvalOperation(int index, this.oval) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addOval(oval);
    return path;
  }

  @override
  PathType get type => PathType.addOval;

  @override
  bool get isCloseEffect => true;

  @override
  List<Cubic>? pickPivot(Path path) {
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    return oval.centerLeft;
  }
}

class ArcOperation extends PathOperation {
  final Rect oval;
  final double startAngle;
  final double sweepAngle;

  const ArcOperation(int index, this.oval, this.startAngle, this.sweepAngle) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addArc(oval, startAngle, sweepAngle);
    return path;
  }

  @override
  PathType get type => PathType.addArc;

  @override
  bool get isCloseEffect => (sweepAngle.abs() % 360) == 0;

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    // TODO: implement pickEndPosition
    throw UnimplementedError();
  }
}

class PolygonOperation extends PathOperation {
  final List<Offset> points;
  final bool close;

  const PolygonOperation(int index, this.points, this.close) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addPolygon(points, close);
    return path;
  }

  @override
  PathType get type => PathType.addPolygon;

  @override
  bool get isCloseEffect => close;

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    return points.last;
  }
}

class RRectOperation extends PathOperation {
  final RRect rrect;

  const RRectOperation(int index, this.rrect) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addRRect(rrect);
    return path;
  }

  @override
  PathType get type => PathType.addRrect;

  @override
  bool get isCloseEffect => true;

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
   return ui.Offset(rrect.left, rrect.bottom-rrect.blRadiusY);
  }
}

class PathPathOperation extends PathOperation {
  final ui.Path path;
  final Offset offset;
  final Float64List? matrix4;

  const PathPathOperation(int index, this.path, this.offset, this.matrix4) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addPath(path, offset, matrix4: matrix4);
    return path;
  }

  @override
  PathType get type => PathType.addPath;

  @override
  // TODO: implement isCloseEffect
  bool get isCloseEffect => throw UnimplementedError();

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }
}

class ExtendPathOperation extends PathOperation {
  final ui.Path path;
  final Offset offset;
  final Float64List? matrix4;

  const ExtendPathOperation(int index, this.path, this.offset, this.matrix4) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.extendWithPath(path, offset, matrix4: matrix4);
    return path;
  }

  @override
  PathType get type => PathType.extendsPath;

  @override
  // TODO: implement isCloseEffect
  bool get isCloseEffect => throw UnimplementedError();

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }
}

class ClosePathOperation extends PathOperation {
  const ClosePathOperation(int index) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.close();
    return path;
  }

  @override
  PathType get type => PathType.close;

  @override
  bool get isCloseEffect => true;

  @override
  List<Cubic>? pickPivot(Path path) {
    // TODO: implement pickPivot
    throw UnimplementedError();
  }

  @override
  ui.Offset? pickEndPosition(Path path) =>null;
}

class ShiftOperation extends UnEffectPathOperation {
  final Offset offset;

  const ShiftOperation(int index, this.offset) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    return path.shift(offset);
  }

  @override
  PathType get type => PathType.shift;

  @override
  ui.Offset? pickEndPosition(Path path)=>null;
}

class TransformPathOperation extends UnEffectPathOperation {
  final Float64List matrix4;

  const TransformPathOperation(int index, this.matrix4) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    return path.transform(matrix4);
  }

  @override
  PathType get type => PathType.transform;

  @override
  ui.Offset? pickEndPosition(Path path) =>null;
}

class PathFillTypeOperation extends UnEffectPathOperation {
  final PathFillType fillType;

  PathFillTypeOperation(int index, this.fillType) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.fillType = fillType;
    return path;
  }

  @override
  PathType get type => PathType.fillType;

  @override
  ui.Offset? pickEndPosition(Path path) =>null;
}

enum PathType {
  move(true),
  line(true),
  quadraticBezier(true),
  cubic(true),
  conic(true),
  arcTo(false),
  arcToPoint(true),
  addRect(false),
  addOval(false),
  addArc(false),
  addPolygon(false),
  addRrect(false),
  addPath(false),
  extendsPath(false),
  close(false),
  shift(false),
  transform(false),
  fillType(false),
  ;

  final bool allowRelative;

  const PathType(this.allowRelative);
}
