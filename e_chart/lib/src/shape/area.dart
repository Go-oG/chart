import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///代表一个封闭的图形
///其路径由给定的上下限点组成
class Area extends CShape {
  static final Area empty = Area([], []);
  List<Offset> upList;
  List<Offset> downList;
  num upSmooth;
  num downSmooth;

  late num ratioStartX;
  late num ratioStartY;
  late num ratioEndX;
  late num ratioEndY;

  Area(
    this.upList,
    this.downList, {
    this.upSmooth = 0,
    this.downSmooth = 0,
    this.ratioStartX = 0.5,
    this.ratioEndX = 0.5,
  }) {
    ratioStartY = 0;
    ratioEndY = 0;
  }

  Area.vertical(
    this.upList,
    this.downList, {
    this.upSmooth = 0,
    this.downSmooth = 0,
    this.ratioStartY = 0.5,
    this.ratioEndY = 0.5,
  }) {
    ratioStartX = 0;
    ratioEndX = 0;
  }

  @override
  Path buildPath() {
    Path path = Path();
    if (upList.length == 1) {
      var first = upList.first;
      path.moveTo(first.dx, first.dy);
    }

    if (upList.length > 1) {
      if (upSmooth > 0) {
        Offset first = upList.first;
        path.moveTo(first.dx, first.dy);
        final int len = upList.length - 1;
        for (int i = 0; i < len; i++) {
          var cur = upList[i];
          var next = upList[i + 1];
          List<Offset> cl = _getCtrPoint(cur, next);
          if (cl.length != 2) {
            path.lineTo(next.dx, next.dy);
          } else {
            var c1 = cl[0];
            var c2 = cl[1];
            path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, next.dx, next.dy);
          }
        }
      } else {
        each(upList, (of, i) {
          if (i == 0) {
            path.moveTo(of.dx, of.dy);
          } else {
            path.lineTo(of.dx, of.dy);
          }
        });
      }
    }

    if (downList.isEmpty) {
      if (upList.length >= 3) {
        path.close();
      }
      return path;
    }
    if (downList.length == 1) {
      var end = downList.last;
      if (upList.isNotEmpty) {
        path.lineTo(end.dx, end.dy);
        path.close();
      } else {
        path.moveTo(end.dx, end.dy);
      }
      return path;
    }

    ///====区域
    Offset end = downList.last;
    if (upList.isNotEmpty) {
      path.lineTo(end.dx, end.dy);
    } else {
      path.moveTo(end.dx, end.dy);
    }
    if (downSmooth <= 0) {
      for (int i = downList.length - 2; i >= 0; i--) {
        var off = downList[i];
        path.lineTo(off.dx, off.dy);
      }
      path.close();
      return path;
    }
    for (int i = downList.length - 1; i >= 1; i--) {
      var cur = downList[i];
      var pre = downList[i - 1];
      List<Offset> cl = _getCtrPoint(cur, pre);
      if (cl.length != 2) {
        path.lineTo(pre.dx, pre.dy);
      } else {
        var s = cl[0];
        var e = cl[1];
        path.cubicTo(s.dx, s.dy, e.dx, e.dy, pre.dx, pre.dy);
      }
    }
    path.close();
    return path;
  }

  ///获取贝塞尔曲线控制点
  List<Offset> _getCtrPoint(Offset start, Offset end) {
    checkArgs(ratioStartX >= 0 && ratioStartX <= 1, "ratioStarX must >=0&&<=1 ");
    checkArgs(ratioStartY >= 0 && ratioStartY <= 1, "ratioStartY must >=0&&<=1");
    checkArgs(ratioEndX >= 0 && ratioEndX <= 1, "ratioEndX must >=0&&<=1");
    checkArgs(ratioEndY >= 0 && ratioEndY <= 1, "ratioEndY must >=0&&<=1");
    if (start.dx == end.dx || start.dy == end.dy) {
      return [];
    }
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double c1x = start.dx + dx * ratioStartX;
    double c1y = start.dy + dy * ratioStartY;
    double c2x = end.dx - dx * ratioEndX;
    double c2y = end.dy - dy * ratioEndY;
    return [
      Offset(c1x, c1y),
      Offset(c2x, c2y),
    ];
  }

  @override
  bool contains(Offset offset) {
    return path.contains(offset);
  }

  @override
  bool get isClosed => true;

  @override
  void dispose() {
    upList.clear();
    downList.clear();
    super.dispose();
  }

  @override
  void render(Canvas2 canvas, Paint paint, CStyle style) {
    style.drawPath(canvas, paint, path, bound);
  }

  @override
  void fill(Attrs attr) {}
}
