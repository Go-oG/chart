import 'dart:math';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'helper.dart';
import 'node.dart';

class DelaunayTransform {
  static const double findRange = 16;
  Fun2<RawData, double> xFun;
  Fun2<RawData, double> yFun;
  bool triangle;

  DelaunayTransform(this.xFun, this.yFun, {this.triangle = true});

  List<RawData> hull = [];

  List<DataNode> transform(Geom series, List<RawData>? input) {
    if (input == null || input.isEmpty) {
      return [];
    }

    bool useTriangle = triangle;
    num left = double.maxFinite;
    num top = double.maxFinite;
    num right = double.minPositive;
    num bottom = double.minPositive;
    if (!useTriangle) {
      input.each((p0, p1) {
        var dx = xFun.call(p0);
        var dy = yFun.call(p0);
        left = min(left, dx);
        top = min(top, dy);
        right = max(right, dx);
        bottom = max(bottom, dy);
      });
    }

    var de = Delaunay<RawData>(input, (a) => xFun.call(a), (b) => yFun.call(b));
    hull = de.getHull();
    var hullPath = Path();
    hull.each((p0, p1) {
      var dx = xFun.call(p0);
      var dy = yFun.call(p0);
      if (p1 == 0) {
        hullPath.moveTo(dx, dy);
      } else {
        hullPath.lineTo(dx, dy);
      }
    });
    hullPath.close();

    List<DelaunayNode> resultList = [];

    de.eachShape(useTriangle, (sp, index) {
      DelaunayNode node;
      if (useTriangle) {
        node = DelaunayNode(series, List.from(sp), index: index);
        node.shape = Polygon(node.points);
      } else {
        ///修剪边缘
        bool has = false;
        for (var p0 in sp) {
          if (!hullPath.contains(p0.toOffset())) {
            has = true;
            break;
          }
        }
        var sd = DelaunayNode(series, List.from(sp), index: index);
        if (has) {
          sd.shape = PathShape(Path.combine(PathOperation.intersect, hullPath, Polygon(sd.points).path));
        }
        node = sd;
      }
      resultList.add(node);
    });
    return resultList;
  }
}
