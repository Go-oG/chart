import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

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
    _list.add(PathFillTypeOperation(value));
    _path.fillType = value;
  }

  void moveTo(double x, double y) {
    _list.add(MoveOperation(false, x, y));
    _path.moveTo(x, y);
  }

  void relativeMoveTo(double dx, double dy) {
    _list.add(MoveOperation(true, dx, dy));
    _path.relativeMoveTo(dx, dy);
  }

  void lineTo(double x, double y) {
    _list.add(LineOperation(false, x, y));
    _path.lineTo(x, y);
  }

  void relativeLineTo(double dx, double dy) {
    _list.add(LineOperation(true, dx, dy));
    _path.relativeLineTo(dx, dy);
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _list.add(QuadraticBezierOperation(false, x1, y1, x2, y2));
    _path.quadraticBezierTo(x1, y1, x2, y2);
  }

  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    _list.add(QuadraticBezierOperation(true, x1, y1, x2, y2));
    _path.relativeQuadraticBezierTo(x1, y1, x2, y2);
  }

  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    _list.add(CubicOperation(false, x1, y1, x2, y2, x3, y3));
    _path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  void relativeCubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    _list.add(CubicOperation(true, x1, y1, x2, y2, x3, y3));
    _path.relativeCubicTo(x1, y1, x2, y2, x3, y3);
  }

  void conicTo(double x1, double y1, double x2, double y2, double w) {
    _list.add(ConicOperation(false, x1, y1, x2, y2, w));
    _path.conicTo(x1, y1, x2, y2, w);
  }

  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    _list.add(ConicOperation(true, x1, y1, x2, y2, w));
    _path.relativeConicTo(x1, y1, x2, y2, w);
  }

  void arcTo(Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    _list.add(ArcToOperation(rect, startAngle, sweepAngle, forceMoveTo));
    _path.arcTo(rect, startAngle, sweepAngle, forceMoveTo);
  }

  void arcToPoint(
    Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    _list.add(ArcToPointOperation(false, arcEnd, radius, rotation, largeArc, clockwise));
    _path.arcToPoint(arcEnd, radius: radius, rotation: rotation, largeArc: largeArc, clockwise: clockwise);
  }

  void relativeArcToPoint(
    Offset arcEndDelta, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    _list.add(ArcToPointOperation(true, arcEndDelta, radius, rotation, largeArc, clockwise));
    _path.relativeArcToPoint(
      arcEndDelta,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  void addRect(Rect rect) {
    _list.add(RectOperation(rect));
    _path.addRect(rect);
  }

  void addOval(Rect oval) {
    _list.add(OvalOperation(oval));
    _path.addOval(oval);
  }

  void addArc(Rect oval, double startAngle, double sweepAngle) {
    _list.add(ArcOperation(oval, startAngle, sweepAngle));
    _path.addArc(oval, startAngle, sweepAngle);
  }

  void addPolygon(List<Offset> points, bool close) {
    _list.add(PolygonOperation(points, close));
    _path.addPolygon(points, close);
  }

  void addRRect(RRect rrect) {
    _list.add(RRectOperation(rrect));
    _path.addRRect(rrect);
  }

  void addPath(ui.Path path, Offset offset, {Float64List? matrix4}) {
    _list.add(PathPathOperation(path, offset, matrix4));
    _path.addPath(path, offset, matrix4: matrix4);
  }

  void extendWithPath(ui.Path path, Offset offset, {Float64List? matrix4}) {
    _list.add(ExtendPathOperation(path, offset, matrix4));
    _path.extendWithPath(path, offset, matrix4: matrix4);
  }

  void close() {
    _list.add(const ClosePathOperation());
    _path.close();
  }

  void reset() {
    _list.clear();
    _path.reset();
  }

  bool contains(Offset point) => _path.contains(point);

  Path shift(Offset offset) {
    List<PathOperation> list = List.from(_list);
    list.add(ShiftOperation(offset));

    var path = _path.shift(offset);
    var result = Path._(path);
    result._list.addAll(list);
    return result;
  }

  Path transform(Float64List matrix4) {
    List<PathOperation> list = List.from(_list);
    list.add(TransformPathOperation(matrix4));
    var path = _path.transform(matrix4);
    var result = Path._(path);
    result._list.addAll(list);
    return result;
  }

  Rect getBounds() => _path.getBounds();

  static ui.Path lerp(Path start, Path end, double progress) {

  }

}

abstract class PathOperation {
  final bool relative;

  const PathOperation(this.relative);

  ui.Path reappear(ui.Path path);

  PathType get type;
}

class MoveOperation extends PathOperation {
  final double x;
  final double y;

  const MoveOperation(super.relative, this.x, this.y);

  @override
  ui.Path reappear(ui.Path path) {
    relative ? path.relativeMoveTo(x, y) : path.moveTo(x, y);
    return path;
  }

  @override
  PathType get type => PathType.move;
}

class LineOperation extends PathOperation {
  final double x;
  final double y;

  const LineOperation(super.relative, this.x, this.y);

  @override
  ui.Path reappear(ui.Path path) {
    relative ? path.relativeLineTo(x, y) : path.lineTo(x, y);
    return path;
  }

  @override
  PathType get type => PathType.line;
}

class QuadraticBezierOperation extends PathOperation {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  const QuadraticBezierOperation(super.relative, this.x1, this.y1, this.x2, this.y2);

  @override
  ui.Path reappear(ui.Path path) {
    relative ? path.relativeQuadraticBezierTo(x1, y1, x2, y2) : path.quadraticBezierTo(x1, y1, x2, y2);
    return path;
  }

  @override
  PathType get type => PathType.quadraticBezier;
}

class CubicOperation extends PathOperation {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  final double x3;
  final double y3;

  const CubicOperation(super.relative, this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);

  @override
  ui.Path reappear(ui.Path path) {
    relative ? path.relativeCubicTo(x1, y1, x2, y2, x3, y3) : path.cubicTo(x1, y1, x2, y2, x3, y3);
    return path;
  }

  @override
  PathType get type => PathType.cubic;
}

class ConicOperation extends PathOperation {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  final double w;

  const ConicOperation(super.relative, this.x1, this.y1, this.x2, this.y2, this.w);

  @override
  ui.Path reappear(ui.Path path) {
    relative ? path.relativeConicTo(x1, y1, x2, y2, w) : path.conicTo(x1, y1, x2, y2, w);

    return path;
  }

  @override
  PathType get type => PathType.conic;
}

class ArcToOperation extends PathOperation {
  final Rect rect;
  final double startAngle;
  final double sweepAngle;
  final bool forceMoveTo;

  const ArcToOperation(this.rect, this.startAngle, this.sweepAngle, this.forceMoveTo) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    path.arcTo(rect, startAngle, sweepAngle, forceMoveTo);
    return path;
  }

  @override
  PathType get type => PathType.arcTo;
}

class ArcToPointOperation extends PathOperation {
  final Offset arcEnd;
  final Radius radius;
  final double rotation;
  final bool largeArc;
  final bool clockwise;

  const ArcToPointOperation(super.relative, this.arcEnd, this.radius, this.rotation, this.largeArc, this.clockwise);

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
}

class RectOperation extends PathOperation {
  final Rect rect;

  const RectOperation(this.rect) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addRect(rect);
    return path;
  }

  @override
  PathType get type => PathType.addRect;
}

class OvalOperation extends PathOperation {
  final Rect oval;

  const OvalOperation(this.oval) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addOval(oval);
    return path;
  }

  @override
  PathType get type => PathType.addOval;
}

class ArcOperation extends PathOperation {
  final Rect oval;
  final double startAngle;
  final double sweepAngle;

  const ArcOperation(this.oval, this.startAngle, this.sweepAngle) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addArc(oval, startAngle, sweepAngle);
    return path;
  }

  @override
  PathType get type => PathType.addArc;
}

class PolygonOperation extends PathOperation {
  final List<Offset> points;
  final bool close;

  const PolygonOperation(this.points, this.close) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addPolygon(points, close);
    return path;
  }

  @override
  PathType get type => PathType.addPolygon;
}

class RRectOperation extends PathOperation {
  final RRect rrect;

  const RRectOperation(this.rrect) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addRRect(rrect);
    return path;
  }

  @override
  PathType get type => PathType.addRrect;
}

class PathPathOperation extends PathOperation {
  final ui.Path path;
  final Offset offset;
  final Float64List? matrix4;

  const PathPathOperation(this.path, this.offset, this.matrix4) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addPath(path, offset, matrix4: matrix4);
    return path;
  }

  @override
  PathType get type => PathType.addPath;
}

class ExtendPathOperation extends PathOperation {
  final ui.Path path;
  final Offset offset;
  final Float64List? matrix4;

  const ExtendPathOperation(this.path, this.offset, this.matrix4) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    path.extendWithPath(path, offset, matrix4: matrix4);
    return path;
  }

  @override
  PathType get type => PathType.extendsPath;
}

class ClosePathOperation extends PathOperation {
  const ClosePathOperation() : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    path.close();
    return path;
  }

  @override
  PathType get type => PathType.close;
}

class ShiftOperation extends PathOperation {
  final Offset offset;

  const ShiftOperation(this.offset) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    return path.shift(offset);
  }

  @override
  PathType get type => PathType.shift;
}

class TransformPathOperation extends PathOperation {
  final Float64List matrix4;

  const TransformPathOperation(this.matrix4) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    return path.transform(matrix4);
  }

  @override
  PathType get type => PathType.transform;
}

class PathFillTypeOperation extends PathOperation {
  final PathFillType fillType;

  PathFillTypeOperation(this.fillType) : super(false);

  @override
  ui.Path reappear(ui.Path path) {
    path.fillType = fillType;
    return path;
  }

  @override
  PathType get type => PathType.fillType;
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
