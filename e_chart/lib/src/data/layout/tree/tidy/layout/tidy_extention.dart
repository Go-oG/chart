import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/data/layout/tree/tidy/model.dart';

import 'basic_layout.dart';

extension TidyTreeExt on TreeNode {
  void resetParentLinkOfChildren() {
    if (children.isEmpty) {
      return;
    }
    for (var item in children) {
      item.parent = this;
    }
  }

  TreeNode appendChild(TreeNode child) {
    child.parent = this;
    child.resetParentLinkOfChildren();
    children.add(child);
    return child;
  }

  bool intersects(TreeNode other) {
    return x - width / 2 < x + other.width / 2 &&
        x + width / 2 > other.x - other.width / 2 &&
        y < other.y + other.height &&
        y + height > other.y;
  }

  void postOrderTraversal(void Function(TreeNode node) f) {
    List<Pair<TreeNode, bool>> stack = [Pair(this, true)];
    while (stack.isNotEmpty) {
      var node = stack.removeLast();
      if (!node.second) {
        f.call(node.first);
        continue;
      }
      stack.add(Pair(node.first, false));
      for (var child in node.first.children) {
        stack.add(Pair(child, true));
      }
    }
  }

  void preOrderTraversal(void Function(TreeNode) f) {
    eachBefore((node, a, b) {
      f.call(node);
      return false;
    });
  }

  void removeChild(String id) {
    children.removeWhere((e) => e.id == id);
  }

  void preOrderTraversalWithDepth(void Function(TreeNode, int) f) {
    List<Pair<TreeNode, int>> stack = [Pair(this, 0)];

    while (stack.isNotEmpty) {
      var tmp = stack.removeLast();
      var node = tmp.first;
      var depth = tmp.second;

      f.call(node, depth);
      for (var child in node.children) {
        stack.add(Pair(child, depth - 1));
      }
    }
  }

  double get bottom => height + y;

  TidyData get tidy {
    return tidyNull!;
  }

  set tidy(TidyData? v) {
    putAttr("tidyData", v);
  }

  TidyData? get tidyNull {
    return getAttr2("tidyData") as TidyData?;
  }

  set bbox(BoundingBox? v) {
    putAttr("bbox", v);
  }

  BoundingBox get bbox {
    return getAttr2("bbox") as BoundingBox;
  }

  void setExtreme() {
    var tidy = this.tidy;
    if (children.isEmpty) {
      tidy.extremeLeft = this;
      tidy.extremeRight = this;
      tidy.modifierExtremeLeft = 0;
      tidy.modifierExtremeRight = 0;
    } else {
      var first = children.first.tidy;
      tidy.extremeLeft = first.extremeLeft;
      tidy.modifierExtremeLeft = first.modifierToSubtree + first.modifierExtremeLeft;
      var last = children.last.tidy;
      tidy.extremeRight = last.extremeRight;
      tidy.modifierExtremeRight = last.modifierToSubtree + last.modifierExtremeRight;
    }
  }

  TreeNode get extremeLeft => tidy.extremeLeft!;

  TreeNode get extremeRight => tidy.extremeRight!;

  double get relativeX => (getAttr("relativeX", 0) as num).toDouble();

  set relativeX(double v) => putAttr("relativeX", v);

  double get relativeY => (getAttr("relativeY", 0) as num).toDouble();

  set relativeY(double v) => putAttr("relativeY", v);

  void positionRoot() {
    var first = children.first;
    var firstChildPos = first.relativeX + first.tidy.modifierToSubtree;
    var last = children.last;
    var lastChildPos = last.relativeX + last.tidy.modifierToSubtree;
    relativeX = (firstChildPos + lastChildPos) / 2;
    tidy.modifierToSubtree = -relativeX;
  }

  void addChildSpacing() {
    double speed = 0;
    double delta = 0;
    for (var child in children) {
      speed += child.tidy.shiftAcceleration;
      delta += speed + child.tidy.shiftChange;
      child.tidy.modifierToSubtree += delta;
      child.tidy.shiftAcceleration = 0;
      child.tidy.shiftChange = 0;
    }
  }
}
