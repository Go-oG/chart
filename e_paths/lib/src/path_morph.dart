import 'dart:math';
import 'dart:ui' as ui;

import 'package:e_paths/src/cubic.dart';
import 'package:e_paths/src/path.dart';

class PathMorph {
  final Path start;
  final Path end;

  List<PathLevel> _startList = [];
  List<PathLevel> _endList = [];

  PathMorph(this.start, this.end) {
    _startList = _compute(start);
    _endList = _compute(end);
  }

  List<List<ui.Offset>> getControlPoints(bool start) {
    List<List<ui.Offset>> list = [];
    final tt = start ? _startList : _endList;
    for (var item in tt) {
      for (var ll in item) {
        for (var c in ll) {
          list.add([c.start, c.control1, c.control2, c.end]);
        }
      }
    }
    return list;
  }

  List<PathLevel> _compute(Path path) {
    List<List<PathSegment>> result = [];
    List<PathSegment> next = [];

    for (var item in path.operationList) {
      var rr = item.pickSegment(path);
      if (rr != null) {
        next.add(rr);
      }

      if (item.effectPathLevel) {
        if (next.isNotEmpty) {
          result.add(next);
          next = [];
        }
      }
    }

    if (next.isNotEmpty) {
      result.add(next);
    }
    return result;
  }

  ui.Path lerp(double t) {
    ui.Path resultPath = ui.Path();
    final count = max(_startList.length, _endList.length);
    for (var i = 0; i < count; i++) {
      final startLevel = i < _startList.length ? _startList[i] : _startList.last;
      final endLevel = i < _endList.length ? _endList[i] : _endList.last;
      var list = _lerpLevel(startLevel, endLevel, t);
      bool hasMove = false;
      for (var cubics in list) {
        for (var cubic in cubics) {
          if (!hasMove) {
            hasMove = true;
            resultPath.moveTo(cubic.start.dx, cubic.start.dy);
          }
          resultPath.cubicTo(
              cubic.control1.dx, cubic.control1.dy, cubic.control2.dx, cubic.control2.dy, cubic.end.dx, cubic.end.dy);
        }
      }
    }
    return resultPath;
  }

  List<PathSegment> _lerpLevel(PathLevel start, PathLevel end, double t) {
    int count = max(start.length, end.length);
    List<PathSegment> rl = [];
    for (var i = 0; i < count; i++) {
      final startLevel = i < start.length ? start[i] : start.last;
      final endLevel = i < end.length ? end[i] : end.last;
      rl.add(_lerpEdge(startLevel, endLevel, t));
    }
    return rl;
  }

  List<Cubic> _lerpEdge(List<Cubic> start, List<Cubic> end, double t) {
    if (t == 0) {
      return start;
    }
    if (t == 1) {
      return end;
    }
    List<Cubic> cubicList = [];
    int count = max(start.length, end.length);
    for (var i = 0; i < count; i++) {
      final startCubic = i < start.length ? start[i] : start.last;
      final endCubic = i < end.length ? end[i] : end.last;
      cubicList.add(Cubic.lerp(startCubic, endCubic, t));
    }
    return cubicList;
  }
}

typedef PathLevel = List<PathSegment>;
