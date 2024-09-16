import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'siblings.dart';

class PackTransform extends TreeMapTransform {
  Fun2<RawData, num>? _radiusFun;
  Fun2<RawData, num> _paddingFun = (a) {
    return 3;
  };
  Fun3<RawData, RawData, int>? _sortFun;

  PackTransform(super.parentFun, super.childFun, {super.valueFun});

  @override
  void initData(TreeNode root) {
    super.initData(root);
    if (_sortFun != null) {
      root.sort(_sortFun as Fun3<TreeNode, TreeNode, int>);
    } else {
      root.sort((p0, p1) => (p1.value - p0.value).toInt());
    }
    padding(_paddingFun);
    if (_radiusFun != null) {
      radius(_radiusFun!);
    }
  }

  @override
  void transform(Context context, double width, double height, TreeNode? root) {
    if (root == null) {
      return;
    }
    var shortSide = min(width, height);
    LCG random = DefaultLCG();
    root.x = width / 2;
    root.y = height / 2;
    if (_radiusFun != null) {
      root
          .eachBefore(_radiusLeaf(_radiusFun!))
          .eachAfter(_packChildrenRandom(_paddingFun, 0.5, random))
          .eachBefore(_translateChild(1));
    } else {
      root
          .eachBefore(_radiusLeaf(_defaultRadius))
          .eachAfter(_packChildrenRandom((e) {
            return 0;
          }, 1, random))
          .eachAfter(_packChildrenRandom(_paddingFun, root.r / shortSide, random))
          .eachBefore(_translateChild(shortSide / (2 * root.r)));
    }

    root.each((node, index, startNode) {
      node.shape = Circle(center: node.center, radius: node.r);
      return false;
    });
  }

  PackTransform radius(Fun2<RawData, num> fun1) {
    _radiusFun = fun1;
    return this;
  }

  PackTransform padding(Fun2<RawData, num> fun1) {
    _paddingFun = fun1;
    return this;
  }

  double _defaultRadius(RawData d) {
    return sqrt(valueFun?.call(d) ?? 0);
  }

  Fun4<TreeNode, int, TreeNode, bool> _radiusLeaf(Fun2<RawData, num> radiusFun) {
    return (TreeNode node, int b, TreeNode c) {
      if (node.notChild) {
        double r = max(0, radiusFun.call(node.data)).toDouble();
        node.r = r;
      }
      return false;
    };
  }

  Fun4<TreeNode, int, TreeNode, bool> _packChildrenRandom(Fun2<RawData, num> paddingFun, num k, LCG random) {
    return (TreeNode node, int b, TreeNode c) {
      List<TreeNode> children = node.children;
      if (children.isNotEmpty) {
        int i, n = children.length;
        num r = paddingFun(node.data) * k, e;
        if (r != 0) {
          for (i = 0; i < n; ++i) {
            children[i].r += r;
          }
        }
        e = Siblings.packSiblingsRandom(children, random);
        if (r != 0) {
          for (i = 0; i < n; ++i) {
            children[i].r -= r;
          }
        }
        node.r = e + r.toDouble();
      }
      return false;
    };
  }

  Fun4<TreeNode, int, TreeNode, bool> _translateChild(num k) {
    return (TreeNode node, int b, TreeNode c) {
      var parent = node.parent;
      node.r *= k;
      if (parent != null) {
        node.x = parent.x + k * node.x;
        node.y = parent.y + k * node.y;
      }
      return false;
    };
  }

  @override
  int get showDepth => -1;
}
