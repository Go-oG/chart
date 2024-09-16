import 'dart:math' as math;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

///环形分布
class RadialTreeLayout extends TreeTransform {
  ///旋转角度
  double rotateAngle;

  ///扫过的角度
  double sweepAngle;

  ///是否顺时针
  bool clockwise;

  ///是否使用优化后的布局
  bool useTidy;

  ///只在 [useTidy]为true时使用
  Fun3<TreeNode, TreeNode, num>? splitFun;

  RadialTreeLayout(
    super.parentFun,
    super.childFun, {
    this.rotateAngle = 0,
    this.sweepAngle = 360,
    this.useTidy = false,
    this.clockwise = true,
    this.splitFun,
    super.lineType = LineType.line,
    super.gapFun,
    super.levelGapFun,
    super.levelGapSize,
    super.nodeGapSize,
  });

  @override
  void transform2(Context context, double width, double height, TreeNode root) {
    var center = Offset(this.center.first.convert(width), this.center.last.convert(height));
    int maxDeep = root.findMaxDeep();
    num maxH = 0;
    for (int i = 1; i <= maxDeep; i++) {
      maxH += getLevelGap(i - 1, i);
    }
    List<TreeNode> nodeList = [root];
    List<TreeNode> next = [];
    while (nodeList.isNotEmpty) {
      num v = 0;
      for (var n in nodeList) {
        Size size = n.size;
        v = math.max(v, size.longestSide);
        next.addAll(n.children);
      }
      maxH += v;
      nodeList = next;
      next = [];
    }
    double radius = maxH / 2;
    if (useTidy) {
      _layoutForTidy(context, root, sweepAngle, radius);
    } else {
      _layoutForDendrogram(context, root, sweepAngle, radius);
    }
    root.each((node, index, startNode) {
      Offset c;
      if (clockwise) {
        c = circlePoint(node.y, node.x + rotateAngle, center);
      } else {
        c = circlePoint(node.y, sweepAngle - (node.x + rotateAngle), center);
      }
      node.x = c.dx;
      node.y = c.dy;
      return false;
    });
    root.x = center.dx;
    root.y = center.dy;
  }

  void _layoutForDendrogram(Context context, TreeNode root, double sweepAngle, double radius) {
    root.sort((p0, p1) => p1.height.compareTo(p0.height));
    var layout = TD3DendrogramTransform(parentFun, childFun, direction: Direction2.ttb, useCompactGap: false);
    if (splitFun != null) {
      layout.splitFun = splitFun!;
    }
    layout.transform2(context, sweepAngle, radius, root);
  }

  void _layoutForTidy(Context context, TreeNode root, double sweepAngle, double radius) {
    var layout = TD3TreeTransform(parentFun, childFun, diff: false);
    if (splitFun != null) {
      layout.splitFun = splitFun!;
    }
    layout.transform2(context, sweepAngle, radius, root);
  }
}
