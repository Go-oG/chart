import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///生态树布局
class TDendrogramTransform extends TreeTransform {
  Direction2 direction;

  TDendrogramTransform(
    super.parentFun,
    super.childFun, {
    this.direction = Direction2.ttb,
    super.gapFun,
    super.levelGapFun,
    super.levelGapSize,
    super.lineType,
    super.nodeGapSize,
    super.smooth,
  });

  @override
  void transform2(Context context, double width, double height, TreeNode root) {
    List<num> yList = List.filled(root.treeHeight + 1, 0);
    for (int i = 1; i <= root.treeHeight; i++) {
      num levelGap = getLevelGap(i - 1, i);
      yList[i] = levelGap + yList[i - 1];
    }
    if (direction != Direction2.v && direction != Direction2.h) {
      return _layoutNode(root, direction, yList);
    }
    int c = root.childCount;
    if (c <= 1) {
      Direction2 d = direction == Direction2.v ? Direction2.ttb : Direction2.ltr;
      return _layoutNode(root, d, yList);
    }
    var leftNode = TreeNode(root.geom, root.data, null, []);
    var rightNode = TreeNode(root.geom, root.data, null, []);
    int middle = c ~/ 2;
    List<TreeNode> cd = List.from(root.children);
    root.clear();
    each(cd, (node, i) {
      if (i <= middle) {
        leftNode.add(node);
      } else {
        rightNode.add(node);
      }
    });

    ///重新计算树的深度和高度
    leftNode.setDeep(0, true);
    leftNode.computeHeight();

    rightNode.setDeep(0, true);
    rightNode.computeHeight(0);
    if (direction == Direction2.v) {
      _layoutNode(leftNode, Direction2.btt, yList);
      _layoutNode(rightNode, Direction2.ttb, yList);
    } else {
      _layoutNode(leftNode, Direction2.rtl, yList);
      _layoutNode(rightNode, Direction2.ltr, yList);
    }

    bool b = leftNode.childCount > rightNode.childCount;
    if (b) {
      ///将right 平移到left
      num dx = leftNode.x - rightNode.x;
      num dy = leftNode.y - rightNode.y;
      rightNode.translate(dx, dy);
    } else {
      ///将left 平移到right
      num dx = rightNode.x - leftNode.x;
      num dy = rightNode.y - leftNode.y;
      leftNode.translate(dx, dy);
    }

    ///还原节点层次关系
    root.size = rightNode.size;
    root.x = b ? leftNode.x : rightNode.x;
    root.y = b ? leftNode.y : rightNode.y;
    for (var node in [...leftNode.children, ...rightNode.children]) {
      node.parent = null;
      root.add(node);
    }

    ///还原树的高度和深度
    root.setDeep(0, false);
    root.setTreeHeight(max(leftNode.treeHeight, rightNode.treeHeight), false);
  }

  void _layoutNode(TreeNode root, Direction2 direction, List<num> yList) {
    if (direction == Direction2.v || direction == Direction2.h) {
      throw FlutterError('该方法不支持 Direction2.v 和Direction2.h');
    }
    bool v = direction == Direction2.ttb || direction == Direction2.btt;
    List<TreeNode> leafList = root.leaves();

    root.each((node, index, startNode) {
      if (v) {
        node.y = yList[node.deep].toDouble();
      } else {
        node.x = yList[node.deep].toDouble();
      }
      return false;
    });

    ///处理X轴方向的位置
    num offset = 0;
    TreeNode? preNode;
    List<TreeNode> preLeafList = [];
    Set<TreeNode> preLeafSet = {};
    Map<TreeNode, TreeNode> rightMap = {};
    Map<TreeNode, TreeNode> leftMap = {};
    for (var node in leafList) {
      rightMap[node] = node;
      leftMap[node] = node;
      Size size = node.size;
      if (v) {
        node.x = offset + size.width / 2;
        offset += size.width + getNodeGap(preNode ?? node, node).dx;
      } else {
        node.y = offset + size.height / 2;
        offset += size.height + getNodeGap(preNode ?? node, node).dy;
      }
      if (node.parent != null &&
          (node.parent!.treeHeight - node.treeHeight).abs() == 1 &&
          !preLeafSet.contains(node.parent!)) {
        preLeafList.add(node.parent!);
      }
    }
    List<TreeNode> nextLeafList = [];

    while (preLeafList.isNotEmpty) {
      preLeafSet = {};
      for (var node in preLeafList) {
        TreeNode right, left;
        right = rightMap[node.lastChild] ?? node.leafRight();
        left = leftMap[node.firstChild] ?? node.leafLeft();
        rightMap[node] = right;
        leftMap[node] = left;

        if (v) {
          node.x = (right.x + left.x) / 2;
        } else {
          node.y = (right.y + left.y) / 2;
        }
        var parent = node.parent;
        if (parent != null && (parent.height - node.height).abs() == 1 && !preLeafSet.contains(parent)) {
          nextLeafList.add(parent);
          preLeafSet.add(parent);
        }
      }
      preLeafList = nextLeafList;
      nextLeafList = [];
    }
    if (direction == Direction2.btt) {
      root.bottom2Top();
    } else if (direction == Direction2.rtl) {
      root.right2Left();
    }
  }
}
