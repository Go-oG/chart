import 'dart:math';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/data/layout/tree/tidy/layout/tidy_extention.dart';

class TidyBasicLayout {
  double parentChildMargin = 0;
  double peerMargin = 0;

  TidyBasicLayout({
    this.peerMargin = 0,
    this.parentChildMargin = 0,
  });

  void layout(TreeNode root) {
    root.eachBefore((node, b, c) {
      node.tidy = null;
      node.x = 0;
      node.y = 0;
      node.relativeX = 0;
      node.relativeY = 0;
      return false;
    });

    root.postOrderTraversal((node) {
      updateMeta(node);
    });
    root.preOrderTraversal((node) {
      if (node.parent != null) {
        var parent = node.parent!;
        node.x = parent.x + node.relativeX;
        node.y = parent.y + node.relativeY;
      }
    });
  }

  void partialLayout(TreeNode root, List<TreeNode> changed) {
  }

  void updateMeta(TreeNode node) {
    node.bbox = BoundingBox(totalHeight: node.height, totalWidth: node.width);
    var children = node.children;
    double n = children.length.toDouble();
    if (n > 0) {
      double tempX = 0;
      double maxHeight = 0;

      for (var child in children) {
        child.relativeY = node.height + parentChildMargin;
        child.relativeX = tempX + child.bbox.totalWidth / 2;
        tempX += child.bbox.totalWidth + peerMargin;
        maxHeight = max(child.bbox.totalHeight, maxHeight);
      }

      var childrenWidth = tempX - peerMargin;
      var shiftX = -childrenWidth / 2;
      for (var child in children) {
        child.relativeX += shiftX;
      }

      node.bbox.totalWidth = max(childrenWidth, node.width);
      node.bbox.totalHeight = node.height + parentChildMargin + maxHeight;
    }
  }
}

class BoundingBox {
  double totalWidth = 0;
  double totalHeight = 0;

  BoundingBox({
    this.totalHeight = 0,
    this.totalWidth = 0,
  });
}
