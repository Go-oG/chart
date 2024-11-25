import 'dart:math';
import 'dart:ui' as ui;

import 'package:e_paths/src/cubic.dart';
import 'package:e_paths/src/path.dart';

class PathMorph {
  final Path start;
  final Path end;

  List<SubPath> _startList = [];
  List<SubPath> _endList = [];

  PathMorph(this.start, this.end) {
    _init();
  }

  void _init() {
    final startList = computeSubPath(start);
    final endList = computeSubPath(end);
    _adjustSubPathCount(startList, endList);
    final maxV = startList.length;
    for (var i = 0; i < maxV; i++) {
      _adjustSinglePathBorder(startList[i], endList[i]);
    }
    _startList = startList;
    _endList = endList;
  }

  void _adjustSubPathCount(List<SubPath> startList, List<SubPath> endList) {
    if (startList.length == endList.length) {
      return;
    }
    int fillCount = (startList.length - endList.length).abs();
    final fillList = startList.length < endList.length ? startList : endList;
    while (fillCount > 0) {
      fillList.add(fillList.last);
      fillCount -= 1;
    }
  }

  void _adjustSinglePathBorder(SubPath startPath, SubPath endPath) {
    if (startPath.length == endPath.length) {
      return;
    }
    int fillCount = (startPath.length - endPath.length).abs();
    final fillPath = startPath.length < endPath.length ? startPath : endPath;
    while (fillCount > 0) {
      int index = -1;
      Cubic? cubic;
      for (int i = 0; i < fillPath.length; i++) {
        final cur = fillPath[i];
        if (cubic == null) {
          cubic = cur;
          index = i;
          continue;
        }
        if (cur.length() > cubic.length()) {
          cubic = cur;
          index = i;
        }
      }
      if (index < 0 || cubic == null) {
        break;
      }

      if (index != -1) {
        List<Cubic> splits = cubic.splitParts(2);
        fillPath.borderList.removeAt(index);
        fillPath.borderList.insertAll(index, splits);
        fillCount -= 1;
      }
    }


    // List<Cubic> cubicList = matchCurves(startPath.borderList, endPath.borderList);
    // endPath.borderList.clear();
    // endPath.borderList.addAll(cubicList);
  }

  List<Cubic> matchCurves(List<Cubic> pathA, List<Cubic> pathB) {
    List<Cubic> matchedPathB = List.from(pathB);
    List<List<double>> similarityMatrix = List.generate(pathA.length, (i) => List.generate(pathB.length, (j) => 0.0));
    for (int i = 0; i < pathA.length; i++) {
      for (int j = 0; j < pathB.length; j++) {
        similarityMatrix[i][j] = pathA[i].computeSimilarity(pathB[j]);
      }
    }
    for (int i = 0; i < pathA.length; i++) {
      double minSimilarity = double.infinity;
      int bestMatchIndex = i;
      for (int j = 0; j < pathB.length; j++) {
        if (similarityMatrix[i][j] < minSimilarity) {
          minSimilarity = similarityMatrix[i][j];
          bestMatchIndex = j;
        }
      }
      matchedPathB[i] = pathB[bestMatchIndex];
    }
    return matchedPathB;
  }

  List<List<ui.Offset>> getControlPoints(bool start) {
    List<List<ui.Offset>> list = [];
    final tt = start ? _startList : _endList;
    for (var subPaths in tt) {
      for (var c in subPaths.borderList) {
        list.add([c.start, c.control1, c.control2, c.end]);
      }
    }
    return list;
  }

  static List<SubPath> computeSubPath(Path path) {
    List<SubPath> result = [];

    List<Cubic> borderList = [];

    for (var item in path.operationList) {
      if (item.isStandAlonePath) {
        if (borderList.isNotEmpty) {
          result.add(SubPath(borderList));
          borderList = [];
        }
      }
      var rr = item.pickBorder(path);
      if (rr != null) {
        borderList.addAll(rr);
      }
    }
    if (borderList.isNotEmpty) {
      result.add(SubPath(borderList));
    }
    return result;
  }

  ui.Path lerp(double t, [bool close = false]) {
    if (_startList.length != _endList.length) {
      throw "length must same";
    }
    ui.Path resultPath = ui.Path();
    final count = _startList.length;
    for (var i = 0; i < count; i++) {
      final startSubPath = _startList[i];
      final endSubPath = _endList[i];
      var subPath = SubPath.lerp(startSubPath, endSubPath, t);
      resultPath.addPath(subPath.toPath(close), ui.Offset.zero);
    }
    return resultPath;
  }
}

final class SubPath {
  final List<Cubic> borderList;

  const SubPath(this.borderList);

  int get length => borderList.length;

  Cubic operator [](int i) {
    return borderList[i];
  }

  Cubic get last => borderList.last;

  Cubic get first => borderList.first;

  ui.Path toPath([bool close = false]) {
    bool moveToFirst = true;
    ui.Path resultPath = ui.Path();
    for (var cubic in borderList) {
      if (moveToFirst) {
        moveToFirst = false;
        resultPath.moveTo(cubic.start.dx, cubic.start.dy);
      }
      resultPath.cubicTo(
          cubic.control1.dx, cubic.control1.dy, cubic.control2.dx, cubic.control2.dy, cubic.end.dx, cubic.end.dy);
    }
    if (close) {
      resultPath.close();
    }
    return resultPath;
  }

  static SubPath lerp(SubPath start, SubPath end, double t) {
    if (start.length != end.length) {
      throw "start length must equal end length";
    }
    final count = start.length;
    List<Cubic> rl = [];
    for (var i = 0; i < count; i++) {
      rl.add(Cubic.lerp(start[i], end[i], t));
    }
    return SubPath(rl);
  }
}
