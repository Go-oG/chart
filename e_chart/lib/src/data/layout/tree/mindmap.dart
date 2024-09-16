import 'package:e_chart/e_chart.dart';

///思维导图
class TMindMapTransform extends TreeTransform {
  TMindMapTransform(
    super.parentFun,
    super.childFun, {
    super.gapFun,
    super.levelGapFun,
    super.lineType = LineType.line,
    super.smooth = 0.5,
    super.levelGapSize,
    super.nodeGapSize,
  });

  @override
  void transform2(Context context, double width, double height, TreeNode root) {
    if (root.childCount <= 1) {
      TCompactTransform(
        parentFun,
        childFun,
        levelAlign: Align2.start,
        direction: Direction2.ltr,
        gapFun: gapFun,
        levelGapFun: levelGapFun,
      ).transform2(context, width, height, root);
      return;
    }
    var leftRoot = TreeNode(root.geom, root.data, null, []);
    var rightRoot = TreeNode(root.geom, root.data, null, []);
    int rightTreeSize = (root.childCount / 2).round();
    int i = 0;
    for (var node in root.children) {
      node.parent = null;
      if (i < rightTreeSize) {
        leftRoot.add(node);
      } else {
        rightRoot.add(node);
      }
      i++;
    }

    var leftLayout = TCompactTransform(parentFun, childFun,
        levelAlign: Align2.start, direction: Direction2.rtl, gapFun: gapFun, levelGapFun: levelGapFun);
    leftLayout.transform2(context, width, height, leftRoot);

    var rightLayout = TCompactTransform(parentFun, childFun,
        levelAlign: Align2.start, direction: Direction2.ltr, gapFun: gapFun, levelGapFun: levelGapFun);
    rightLayout.transform2(context, width, height, rightRoot);

    root.children.clear();
    for (var element in leftRoot.children) {
      element.parent = null;
      root.add(element);
    }
    for (var element in rightRoot.children) {
      element.parent = null;
      root.add(element);
    }

    num tx = leftRoot.x - rightRoot.x;
    num ty = leftRoot.y - rightRoot.y;
    rightRoot.each((node, index, startNode) {
      node.x += tx;
      node.y += ty;
      return false;
    });
    root.x = leftRoot.x;
    root.y = leftRoot.y;
  }
}
