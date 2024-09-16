import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
class RectTreeMapTransform extends TreeMapTransform {
  Fun2<RawData, num>? paddingInner;
  Fun2<RawData, num>? paddingLeft;
  Fun2<RawData, num>? paddingTop;
  Fun2<RawData, num>? paddingRight;
  Fun2<RawData, num>? paddingBottom;
  Fun3<RawData, RawData, int>? sortFun;
  bool round;
  bool usePolar;

  //表示展示几层，从0开始计算
  // 如果<=0 则展示全部
  int initShowDepth;

  Offset _center = const Offset(0, 0);

  RectTreeMapTransform(
    super.parentFun,
    super.childFun, {
    super.layout,
    super.valueFun,
    this.round = true,
    this.initShowDepth = 2,
    this.usePolar = false,
  });

  @override
  void initData(TreeNode root) {}

  @override
  void transform(Context context, double width, double height, TreeNode? root) {
    if (root == null) {
      return;
    }
    _center = Offset(width / 2, height / 2);
    bool usePolar = this.usePolar;
    if (usePolar) {
      var ow = width;
      width = 360;
      height = min(ow, height) / 2;
    }

    var sort = sortFun;
    if (sort != null) {
      root.sort((a, b) {
        return sort.call(a.data, b.data);
      }, true);
    }

    root.sum((p0) => p0.value);
    root.setDeep(0);
    root.computeHeight();
    root.setMaxDeep(root.treeHeight);

    root.x = width / 2;
    root.y = height / 2;
    root.width = width;
    root.height = height;

    int c = initShowDepth;
    if (c <= 0) {
      c = root.maxDeep;
    }

    List<List<TreeNode>> levelList = root.levelEach(c);

    each(levelList, (levels, p1) {
      for (var c in levels) {
        _layoutChildren(context, c, c.x, c.y, c.width, c.height);
      }
    });
  }

  void _layoutChildren(Context context, TreeNode parent, double x, double y, double w, double h) {
    parent.x = x;
    parent.y = y;
    parent.width = w;
    parent.height = h;
    if (parent.notChild) {
      return;
    }

    ///处理自身的padding
    var x0 = parent.left - getPaddingLeft(parent);
    var y0 = parent.top - getPaddingTop(parent);
    var x1 = parent.right - getPaddingRight(parent);
    var y1 = parent.bottom - getPaddingBottom(parent);
    if (x1 < x0) x0 = x1 = (x0 + x1) / 2;
    if (y1 < y0) y0 = y1 = (y0 + y1) / 2;
    var cRect = Rect.fromLTRB(x0, y0, x1, y1);
    var option = HierarchyOption(cRect);
    this.layout.onLayout(context, parent, option);

    var paddingInner = getPaddingInner(parent);
    if (paddingInner > 0) {
      double v = paddingInner / 2;
      each(parent.children, (child, p1) {
        child.width -= 2 * v;
        child.height -= 2 * v;
      });
    }
    bool round = this.round;

    each(parent.children, (p0, p1) {
      if (round) {
        _roundNode(p0);
      }
      p0.shape = _builder(p0);
    });
  }

  CShape _builder(DataNode p0) {
    if (usePolar) {
      return Arc(
        innerRadius: p0.top,
        outRadius: p0.bottom,
        startAngle: p0.left,
        sweepAngle: p0.width,
        center: _center,
      );
    }
    return CRect(left: p0.left, top: p0.top, right: p0.right, bottom: p0.bottom);
  }

  num getPaddingInner(TreeNode data) {
    num v = paddingInner?.call(data.data) ?? 0;
    return max(v, 0);
  }

  num getPaddingTop(TreeNode data) {
    num v = paddingTop?.call(data.data) ?? 0;
    return max(v, 0);
  }

  num getPaddingLeft(TreeNode data) {
    num v = paddingLeft?.call(data.data) ?? 0;
    return max(v, 0);
  }

  num getPaddingRight(TreeNode data) {
    num v = paddingRight?.call(data.data) ?? 0;
    return max(v, 0);
  }

  num getPaddingBottom(TreeNode data) {
    num v = paddingBottom?.call(data.data) ?? 0;
    return max(v, 0);
  }

  void _roundNode(TreeNode node) {
    node.width = node.width.roundToDouble();
    node.height = node.height.roundToDouble();
  }

  @override
  int get showDepth => initShowDepth;
}
