import 'dart:ui';
import 'package:e_chart/e_chart.dart';

abstract class TreeTransform extends HierarchyTransform {
  List<SNumber> center;
  bool rootInCenter;

  ///连接线的类型(某些布局只支持某些特定类型)
  LineType lineType;

  ///是否平滑连接线
  double smooth;

  ///节点之间的间距函数
  Offset? nodeGapSize;
  Fun3<TreeNode, TreeNode, Offset>? gapFun;

  ///节点之间的层级间距函数优先级：fun> levelGapSize
  double? levelGapSize;
  Fun3<int, int, double>? levelGapFun;

  TreeTransform(
    super.parentFun,
    super.childFun, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.rootInCenter = true,
    this.lineType = LineType.line,
    this.smooth = 0,
    this.nodeGapSize,
    this.gapFun,
    this.levelGapSize,
    this.levelGapFun,
  });

  @override
  void transform(Context context, double width, double height, TreeNode root) {
    transform2(context, width, height, root);

    ///布局完成计算偏移量并更新节点
    double x = this.center.first.convert(width);
    double y = this.center.last.convert(height);

    ///root中心点坐标
    var center = root.center;
    if (!rootInCenter) {
      center = root.getBoundBox().center;
    }
    double dx = x - center.dx;
    double dy = y - center.dy;

    root.each((node, index, startNode) {
      node.x += dx;
      node.y += dy;
      //  node.shape = _builder(node);
      return false;
    });
  }

  void transform2(Context context, double width, double height, TreeNode root);

  Path? onLayoutNodeLink(TreeNode parent, TreeNode child) {
    List<Offset> ol = [parent.center, child.center];
    if (lineType.ratio >= 0 && lineType.ratio <= 1) {
      ol = Line.step(ol, lineType.ratio);
    }
    return Line(ol, smooth: lineType.isStep() ? 0 : smooth).path;
  }

  ///========普通函数=============
  Offset getNodeGap(TreeNode node1, TreeNode node2) {
    Offset? offset = gapFun?.call(node1, node2) ?? nodeGapSize;
    if (offset != null) {
      return offset;
    }
    return const Offset(8, 8);
  }

  double getLevelGap(int level1, int level2) {
    if (levelGapFun != null) {
      return levelGapFun!.call(level1, level2).toDouble();
    }
    if (levelGapSize != null) {
      return levelGapSize!.toDouble();
    }
    return 24;
  }

  bool get optShowNode => true;
}
