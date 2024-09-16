import 'dart:ui';
import 'package:e_chart/e_chart.dart';

/// 近似平衡二叉树排列
/// 为宽矩形选择水平分区，为高矩形选择垂直分区的布局方式。
/// 由于权重只能为int 因此内部会进行相关的double->int的转换
class BinaryLayout extends HierarchyLayout {
  @override
  void onLayout(Context context, TreeNode data, var option) {
    Rect area = option.rect;
    data.x = area.center.dx;
    data.y = area.center.dy;
    data.size = area.size;
    _layoutChildren(area, data);
  }

  void _layoutChildren(Rect area, TreeNode parent) {
    List<TreeNode> nodeList = parent.children;
    if (nodeList.isEmpty) {
      return;
    }
    List<double> sumList = [0];
    for (var element in nodeList) {
      sumList.add(element.value + sumList.last);
    }

    _partition(
      sumList,
      nodeList,
      0,
      nodeList.length,
      parent.value,
      area.left,
      area.top,
      area.right,
      area.bottom,
    );
  }

  ///分割
  static void _partition(
    List<double> sums,
    List<TreeNode> nodes,
    int start,
    int end,
    num value,
    double left,
    double top,
    double right,
    double bottom,
  ) {
    //无法再分割直接返回
    if (start >= end - 1) {
      TreeNode node = nodes[start];
      node.x = (left + right) / 2;
      node.y = (top + bottom) / 2;
      node.width = right - left;
      node.height = bottom - top;
      return;
    }
    double valueOffset = sums[start];
    double valueTarget = (value / 2) + valueOffset;
    int k = start + 1;
    int hi = end - 1;

    while (k < hi) {
      int mid = k + hi >>> 1;
      if (sums[mid] < valueTarget) {
        k = mid + 1;
      } else {
        hi = mid;
      }
    }

    if ((valueTarget - sums[k - 1]) < (sums[k] - valueTarget) && start + 1 < k) {
      --k;
    }

    double valueLeft = sums[k] - valueOffset;
    double valueRight = value - valueLeft;

    if ((right - left) > (bottom - top)) {
      //宽矩形水平分割
      var xk = (left * valueRight + right * valueLeft) / value;
      _partition(sums, nodes, start, k, valueLeft, left, top, xk, bottom);
      _partition(sums, nodes, k, end, valueRight, xk, top, right, bottom);
    } else {
      // 高矩形垂直分割
      var yk = (top * valueRight + bottom * valueLeft) / value;
      _partition(sums, nodes, start, k, valueLeft, left, top, right, yk);
      _partition(sums, nodes, k, end, valueRight, left, yk, right, bottom);
    }
  }
}
