import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:e_paths/src/path.dart';
import 'package:flutter/semantics.dart';
import 'cubic.dart';

abstract class RawOperation {
  final int index;
  final bool relative;

  const RawOperation(this.index, this.relative);

  ui.Path reappear(ui.Path path);

  PathType get type;

  ///标识该操作是否会创建一个新的层
  bool get effectPathLevel;

  PathSegment? pickSegment(Path path);

  ui.Offset? pickEndPosition(Path path);

  ui.Offset? pickPreLastPosition(Path path) {
    ui.Offset? end;
    for (int i = index - 1; i >= 0; i--) {
      end = path.operationList[i].pickEndPosition(path);
      if (end != null) {
        break;
      }
    }
    return end;
  }
}

abstract class UnEffectPathOperation extends RawOperation {
  const UnEffectPathOperation(super.index, super.relative);

  @override
  bool get effectPathLevel => false;

  @override
  PathSegment? pickSegment(Path path) => null;
}

class MoveOperation extends RawOperation {
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
  bool get effectPathLevel => true;

  @override
  PathSegment? pickSegment(Path path) => null;

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

class LineOperation extends RawOperation {
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
  bool get effectPathLevel => false;

  @override
  PathSegment? pickSegment(Path path) {
    final pre = pickPreLastPosition(path);
    if (pre == null) {
      throw "get pre offset error";
    }
    final end = relative ? pre.translate(x, y) : ui.Offset(x, y);
    return [Cubic.ofLine(pre, end)];
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

class QuadraticBezierOperation extends RawOperation {
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
  bool get effectPathLevel => false;

  @override
  PathSegment? pickSegment(Path path) {
    final pre = pickPreLastPosition(path);
    if (pre == null) {
      throw "get pre offset error";
    }
    final end = relative ? pre.translate(x2, y2) : ui.Offset(x2, y2);
    final control = relative ? pre.translate(x1, y1) : ui.Offset(x1, y1);
    return [Cubic.ofQuadratic(pre, end, control)];
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

class CubicOperation extends RawOperation {
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
  bool get effectPathLevel => false;

  @override
  PathSegment? pickSegment(Path path) {
    final pre = pickPreLastPosition(path);
    if (pre == null) {
      throw "get pre offset error";
    }
    final end = relative ? pre.translate(x3, y3) : ui.Offset(x3, y3);
    final control1 = relative ? pre.translate(x1, y1) : ui.Offset(x1, y1);
    final control2 = relative ? pre.translate(x2, y2) : ui.Offset(x2, y2);
    return [Cubic(pre, end, control1, control2)];
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

class ConicOperation extends RawOperation {
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
  bool get effectPathLevel => false;

  @override
  PathSegment? pickSegment(Path path) {
    final pre = pickPreLastPosition(path);
    if (pre == null) {
      throw "get pre offset error";
    }
    final end = relative ? pre.translate(x2, y2) : ui.Offset(x2, y2);
    final c = relative ? pre.translate(x1, y1) : ui.Offset(x1, y1);

    ui.Offset c1 = pre + (c - pre) * w;
    ui.Offset c2 = end + (c - end) * w;
    return [Cubic(pre, end, c1, c2)];
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

class ArcToOperation extends RawOperation {
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
  bool get effectPathLevel => false;

  @override
  PathSegment? pickSegment(Path path) {
    return [Cubic.ofArc(rect, startAngle, sweepAngle, forceMoveTo)];
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    var angle = (startAngle + sweepAngle) * pi / 180;
    var center = rect.center;
    return ui.Offset(center.dx + cos(angle) * rect.width, center.dy + sin(angle) * rect.height);
  }
}

class ArcToPointOperation extends RawOperation {
  final Offset arcEnd;
  final ui.Radius radius;
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
  bool get effectPathLevel => false;

  @override
  PathSegment? pickSegment(Path path) {
    var pre = pickPreLastPosition(path);
    pre ??= ui.Offset.zero;
    if (relative) {
      return [Cubic.ofArc2(pre, arcEnd + pre, radius, rotation, largeArc, clockwise)];
    } else {
      return [Cubic.ofArc2(pre, arcEnd, radius, rotation, largeArc, clockwise)];
    }
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

class RectOperation extends RawOperation {
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
  bool get effectPathLevel => true;

  @override
  PathSegment? pickSegment(Path path) {
    final topLeft = rect.topLeft;
    final topRight = rect.topRight;
    final bottomRight = rect.bottomRight;
    final bottomLeft = rect.bottomLeft;

    return [
      Cubic.ofLine(topLeft, topRight),
      Cubic.ofLine(topRight, bottomRight),
      Cubic.ofLine(bottomRight, bottomLeft),
      Cubic.ofLine(bottomLeft, topLeft),
    ];
  }

  @override
  ui.Offset? pickEndPosition(Path path) => null;
}

class OvalOperation extends RawOperation {
  final ui.Rect oval;

  const OvalOperation(int index, this.oval) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addOval(oval);
    return path;
  }

  @override
  PathType get type => PathType.addOval;

  @override
  bool get effectPathLevel => true;

  @override
  PathSegment? pickSegment(Path path) {
    return Cubic.ofOval(oval);
  }

  @override
  ui.Offset? pickEndPosition(Path path) => oval.centerLeft;
}

class ArcOperation extends RawOperation {
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
  bool get effectPathLevel => (sweepAngle.abs() % 360) == 0;

  @override
  PathSegment? pickSegment(Path path) {
    return [Cubic.ofArc(oval, startAngle, sweepAngle, false)];
  }

  @override
  ui.Offset? pickEndPosition(Path path) => null;
}

class PolygonOperation extends RawOperation {
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
  bool get effectPathLevel => true;

  @override
  PathSegment? pickSegment(Path path) {
    List<Cubic> result = [];
    ui.Offset? pre;
    for (var item in points) {
      if (pre != null) {
        result.add(Cubic.ofLine(pre, item));
      }
      pre = item;
    }
    if (close) {
      result.add(Cubic.ofLine(pre!, points.first));
    }
    return result;
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    if (close) {
      return points.firstOrNull;
    }
    return points.lastOrNull;
  }
}

class RRectOperation extends RawOperation {
  final ui.RRect rrect;

  const RRectOperation(int index, this.rrect) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.addRRect(rrect);
    return path;
  }

  @override
  PathType get type => PathType.addRrect;

  @override
  bool get effectPathLevel => true;

  @override
  PathSegment? pickSegment(Path path) {
    return Cubic.ofRRect(rrect);
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    return ui.Offset(rrect.left, rrect.bottom - rrect.blRadiusY);
  }
}

class PathPathOperation extends RawOperation {
  final Path path;
  final ui.Offset offset;
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
  bool get effectPathLevel => true;

  @override
  PathSegment? pickSegment(Path path) {
    List<Cubic> list = [];
    for (var item in this.path.pickSegment()) {
      for (var item2 in item) {
        list.addAll(item2);
      }
    }
    return list;
  }

  @override
  ui.Offset? pickEndPosition(Path path) => Path.lastOffset(this.path.rawPath);
}

class ExtendPathOperation extends RawOperation {
  final ui.Path path;
  final ui.Offset offset;
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
  bool get effectPathLevel => true;

  @override
  PathSegment? pickSegment(Path path) {
    List<Cubic> cl = [];
    for (var item in path.pickSegment()) {
      for (var cu in item) {
        cl.addAll(cu);
      }
    }
    return cl;
  }

  @override
  ui.Offset? pickEndPosition(Path path) {
    if (matrix4 != null) {
      var ma = Matrix4.fromFloat64List(matrix4!);
      ma.translate(offset.dx, offset.dy);
      return Path.lastOffset(this.path.transform(ma.storage));
    } else {
      var end = Path.lastOffset(this.path);
      if (end != null) {
        return end.translate(offset.dx, offset.dy);
      }
    }
    return null;
  }
}

class ClosePathOperation extends RawOperation {
  const ClosePathOperation(int index) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.close();
    return path;
  }

  @override
  PathType get type => PathType.close;

  @override
  bool get effectPathLevel => true;

  @override
  PathSegment? pickSegment(Path path) {
    var end = pickPreLastPosition(path);
    end ??= ui.Offset.zero;
    ui.Offset first = end;
    RawOperation? ope;
    for (int i = index - 1; i >= 0; i--) {
      ope ??= path.operationList[i];

      if (ope.effectPathLevel) {
        break;
      }
    }
    var tmp = ope?.pickEndPosition(path);
    if (tmp != null) {
      first = tmp;
    }
    return [Cubic.ofLine(end, first)];
  }

  @override
  ui.Offset? pickEndPosition(Path path) => null;
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
  ui.Offset? pickEndPosition(Path path) => null;
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
  ui.Offset? pickEndPosition(Path path) => null;
}

class PathFillTypeOperation extends UnEffectPathOperation {
  final ui.PathFillType fillType;

  PathFillTypeOperation(int index, this.fillType) : super(index, false);

  @override
  ui.Path reappear(ui.Path path) {
    path.fillType = fillType;
    return path;
  }

  @override
  PathType get type => PathType.fillType;

  @override
  ui.Offset? pickEndPosition(Path path) => null;
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
  fillType(false);

  final bool allowRelative;

  const PathType(this.allowRelative);
}
