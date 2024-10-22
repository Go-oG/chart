import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/data/layout/tree/tidy/layout/tidy_extention.dart';

import '../model.dart';
import 'basic_layout.dart';
import 'linked_y_list.dart';

class TidyContour {
  bool isLeft;
  TreeNode? current;
  double modifierSum;

  TidyContour(this.isLeft, this.current, this.modifierSum);

  factory TidyContour.build(bool isLeft, TreeNode current) {
    return TidyContour(isLeft, current, current.tidy.modifierToSubtree);
  }

  bool get isNone => current == null;

  double get left {
    var node = current!;
    return modifierSum + node.relativeX - node.width / 2;
  }

  double get right {
    var node = current!;
    return modifierSum + node.relativeX + node.width / 2;
  }

  double get bottom {
    var node = current;
    if (node == null) {
      return 0;
    }
    return node.y + node.height;
  }

  TreeNode get node => current!;

  void next() {
    if (current != null) {
      var node = current!;
      if (isLeft) {
        if (node.children.isNotEmpty) {
          current = node.children.first;
          node = current!;
          modifierSum += node.tidy.modifierToSubtree;
        } else {
          modifierSum += node.tidy.modifierThreadLeft;
          current = node.tidy.threadLeft;
        }
      } else if (node.children.isNotEmpty) {
        current = node.children.last;
        node = current!;
        modifierSum += node.tidy.modifierToSubtree;
      } else {
        modifierSum += node.tidy.modifierThreadRight;
        current = node.tidy.threadRight;
      }

      if (current != null) {
        node = current!;
      }
    }
  }
}

class TidyLayout extends TidyBasicLayout {
  late bool isLayered;

  late List<double> depthToY = [];

  TidyLayout({
    this.isLayered = false,
    this.depthToY = const [],
    super.parentChildMargin,
    super.peerMargin,
  });

  factory TidyLayout.ofLayered(double parentChildMargin, double peerMargin) {
    return TidyLayout(parentChildMargin: parentChildMargin, peerMargin: peerMargin, isLayered: true, depthToY: []);
  }

  LinkedYList? separate(
    TreeNode node,
    int childIndex,
    LinkedYList? yList,
  ) {
    var left = TidyContour.build(false, node.children[childIndex - 1]);
    var right = TidyContour.build(true, node.children[childIndex]);
    while (!left.isNone && !right.isNone) {
      if (left.bottom > yList!.bottom) {
        var b = yList.bottom;
        var top = yList.pop();
        if (top == null) {
          print("Err\n\n$node\n\nleft.bottom=${left.bottom}\nyList.bottom=$b");
        }
        yList = top;
      }
      var dist = left.right - right.left + peerMargin;
      if (dist > 0) {
        right.modifierSum += dist;
        moveSubtree(node, childIndex, yList!.index, dist);
      }
      var leftBottom = left.bottom;
      var rightBottom = right.bottom;
      if (leftBottom <= rightBottom) {
        left.next();
      }
      if (leftBottom >= rightBottom) {
        right.next();
      }
    }

    if (left.isNone && !right.isNone) {
      setLeft(node, childIndex, right.node, right.modifierSum);
    } else if (!left.isNone && right.isNone) {
      setRight(node, childIndex, left.node, left.modifierSum);
    }

    return yList;
  }

  void setLeft(TreeNode node, int currentIndex, TreeNode? target, double modifier) {
    var first = node.children[0];
    var current = node.children[currentIndex];
    var diff = modifier - first.tidy.modifierExtremeLeft - first.tidy.modifierToSubtree;
    first.extremeLeft.tidy.threadLeft = target;
    first.extremeLeft.tidy.modifierThreadLeft = diff;
    first.tidy.extremeLeft = current.tidy.extremeLeft;
    first.tidy.modifierExtremeLeft =
        current.tidy.modifierExtremeLeft + current.tidy.modifierToSubtree - first.tidy.modifierToSubtree;
  }

  void setRight(TreeNode node, int currentIndex, TreeNode target, double modifier) {
    var current = node.children[currentIndex];
    var diff = modifier - current.tidy.modifierExtremeRight - current.tidy.modifierToSubtree;
    current.extremeRight.tidy.threadRight = target;
    current.extremeRight.tidy.modifierThreadRight = diff;
    var prev = node.children[currentIndex - 1].tidy;
    current.tidy.extremeRight = prev.extremeRight;
    current.tidy.modifierExtremeRight =
        prev.modifierExtremeRight + prev.modifierToSubtree - current.tidy.modifierToSubtree;
  }

  void moveSubtree(
    TreeNode node,
    int currentIndex,
    int fromIndex,
    double distance,
  ) {
    var child = node.children[currentIndex];
    var childTidy = child.tidy;
    childTidy.modifierToSubtree += distance;

    if (fromIndex != currentIndex - 1) {
      var indexDiff = (currentIndex - fromIndex).toDouble();
      node.children[fromIndex + 1].tidy.shiftAcceleration += distance / indexDiff;
      node.children[currentIndex].tidy.shiftAcceleration -= distance / indexDiff;
      node.children[currentIndex].tidy.shiftChange -= distance - distance / indexDiff;
    }
  }

  void setYRecursive(TreeNode root) {
    if (!isLayered) {
      root.preOrderTraversal((node) {
        setY(node);
      });
    } else {
      var depthToY = this.depthToY;
      depthToY.clear();
      root.bfsEach((node, depth) {
        while (depth >= depthToY.length) {
          depthToY.add(0);
        }

        if (node.parent == null || depth == 0) {
          node.y = 0;
          return;
        }

        var parent = node.parent!;
        depthToY[depth] = max(
          depthToY[depth],
          depthToY[depth - 1] + parent.height + parentChildMargin,
        );
      });
      root.preOrderTraversalWithDepth((node, depth) {
        node.y = depthToY[depth];
      });
    }
  }

  void setY(TreeNode node) {
    if (node.parent != null) {
      var parentBottom = node.parent!.bottom;
      node.y = parentBottom + parentChildMargin;
    } else {
      node.y = 0;
    }
  }

  void firstWalk(TreeNode node) {
    if (node.children.isEmpty) {
      node.setExtreme();
      return;
    }

    firstWalk(node.children.first);
    var yList = LinkedYList(0, node.children[0].extremeRight.bottom, null);
    for (int i = 1; i < node.children.length; i++) {
      var currentChild = node.children[i];
      firstWalk(currentChild);
      var maxY = currentChild.extremeLeft.bottom;
      yList = separate(node, i, yList)!;
      yList = yList.update(i, maxY);
    }
    node.positionRoot();
    node.setExtreme();
  }

  void firstWalkWithFilter(TreeNode node, Set<String> set) {
    if (!set.contains(node.id)) {
      invalidateExtreme(node);
      return;
    }

    if (node.children.isEmpty) {
      node.setExtreme();
      return;
    }

    firstWalkWithFilter(node.children.first, set);
    var yList = LinkedYList(0, node.children[0].extremeRight.bottom, null);
    for (int i = 1; i < node.children.length; i++) {
      var currentChild = node.children[i];
      currentChild.tidy.modifierToSubtree = -currentChild.relativeX;
      firstWalkWithFilter(currentChild, set);
      var maxY = currentChild.extremeLeft.bottom;
      yList = separate(node, i, yList)!;
      yList = yList.update(i, maxY);
    }

    node.positionRoot();
    node.setExtreme();
  }

  void secondWalk(TreeNode node, double modSum) {
    modSum += node.tidy.modifierToSubtree;
    node.x = node.relativeX + modSum;
    node.addChildSpacing();
    for (var child in node.children) {
      secondWalk(child, modSum);
    }
  }

  void secondWalkWithFilter(TreeNode node, double modSum, Set<String> set) {
    modSum += node.tidy.modifierToSubtree;
    var newX = node.relativeX + modSum;
    if ((newX - node.x).abs() < 1e-8 && !set.contains(node.id)) {
      return;
    }

    node.x = newX;
    node.addChildSpacing();
    for (var child in node.children) {
      secondWalkWithFilter(child, modSum, set);
    }
  }

  @override
  void layout(TreeNode root) {
    root.preOrderTraversal(initNode);
    setYRecursive(root);
    firstWalk(root);
    secondWalk(root, 0);
  }

  @override
  void partialLayout(TreeNode root, List<TreeNode> changed) {
    if (isLayered) {
      layout(root);
      return;
    }

    for (var node in changed) {
      if (node.tidyNull == null) {
        initNode(node);
      }
      setYRecursive(node);
    }

    Set<String> set = <String>{};
    for (var node in changed) {
      set.add(node.id);
      while (node.parent != null) {
        invalidateExtreme(node);
        set.add(node.parent!.id);
        node = node.parent!;
      }
    }
    firstWalkWithFilter(root, set);
    secondWalkWithFilter(root, 0, set);
  }

  void initNode(TreeNode node) {
    var tidy = node.tidyNull;
    if (tidy != null) {
      tidy.extremeLeft = null;
      tidy.extremeRight = null;
      tidy.shiftAcceleration = 0;
      tidy.shiftChange = 0;
      tidy.modifierToSubtree = 0;
      tidy.modifierExtremeLeft = 0;
      tidy.modifierExtremeRight = 0;
      tidy.threadLeft = null;
      tidy.threadRight = null;
      tidy.modifierThreadLeft = 0;
      tidy.modifierThreadRight = 0;
    } else {
      node.tidy = TidyData(extremeLeft: null, extremeRight: null, threadLeft: null, threadRight: null);
    }

    node.x = 0;
    node.y = 0;
    node.relativeX = 0;
    node.relativeY = 0;
  }

  void invalidateExtreme(TreeNode node) {
    node.setExtreme();
    var left = node.extremeLeft.tidy;
    left.threadLeft = null;
    left.threadRight = null;
    left.modifierThreadLeft = 0;
    left.modifierThreadRight = 0;
    var right = node.extremeRight.tidy;
    right.threadLeft = null;
    right.threadRight = null;
    right.modifierThreadLeft = 0;
    right.modifierThreadRight = 0;
  }
}
