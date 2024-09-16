import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:e_chart/e_chart.dart';

import '../util.dart';


/// 从上到下
class SliceLayout extends HierarchyLayout {
  @override
  void onLayout(Context context, TreeNode data, var option) {
    layoutChildren(option.rect, data.children);
  }

  ///从上到下
  static void layoutChildren(Rect rect, List<TreeNode> nodeList) {
    double w = rect.width;
    double h = rect.height;
    double allValue = computeAllRatio(nodeList);
    double topOffset = rect.top;
    for (var node in nodeList) {
      double ratio = node.areaRatio / allValue;
      double h2 = ratio * h;
      node.x = rect.left + w / 2;
      node.y = topOffset + h2 / 2;
      node.width = w;
      node.height = h2;

      topOffset += h2;
    }
  }
}
