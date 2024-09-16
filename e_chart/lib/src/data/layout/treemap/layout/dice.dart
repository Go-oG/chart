import 'dart:ui';
import 'package:flutter/widgets.dart';

import 'package:e_chart/e_chart.dart';
import '../util.dart';

//从左至右
class DiceLayout extends HierarchyLayout {
  @override
  void onLayout(Context context, TreeNode data, var option) {
    if (data.notChild) {
      return;
    }
    layoutChildren(option.rect, data.children);
  }

  static void layoutChildren(Rect area, List<TreeNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    double leftOffset = area.left;
    double w = area.width;
    double h = area.height;
    num allRatio = computeAllRatio(nodeList);
    for (var node in nodeList) {
      double p = node.areaRatio / allRatio;
      double w2 = w * p;

      node.x = leftOffset + w2 / 2;
      node.y = area.top + h / 2;
      node.width = w2;
      node.height = h;

      leftOffset += w2;
    }
  }
}
