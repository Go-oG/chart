import 'dart:math';

import 'package:e_chart/e_chart.dart';

import 'g_transform.dart';
///随机布局
class GRandomTransform extends GTransform {
  List<SNumber> center;

  ///用于处理重叠时的迭代次数
  int maxIterations;

  GRandomTransform(
    super.childFun, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.maxIterations = 30,
    super.nodeSpaceFun,
    super.sort,
  });

  @override
  void transform(Context context, double width, double height, Graph? graph) {
    if (graph == null) {
      return;
    }
    QuadTree<GraphNode> tree = QuadTree((p0) => p0.x, (p0) => p0.y, 0, 0, width, height);
    List<GraphNode> nodes = [...graph.nodes];
    if (sort != null) {
      Map<GraphNode, num> sortMap = sort!.call(nodes);
      nodes.sort((a, b) {
        return (sortMap[a] ?? 0).compareTo((sortMap[b] ?? 0));
      });
    }
    var random = Random();
    for (var node in nodes) {
      num nspace = getNodeSpace(node);
      int c = maxIterations;
      while (c > 0) {
        double x = random.nextDouble() * width;
        double y = random.nextDouble() * height;
        if (!hasCover(tree, x, y, node.r, nspace) || c == 1) {
          node.x = x;
          node.y = y;
          tree.add(node);
          break;
        }
        c--;
      }
    }
  }

  bool hasCover(QuadTree<GraphNode> tree, double x, double y, num r, num space) {
    bool covered = false;
    tree.each((node, x1, y1, x2, y2) {
      if (covered) {
        return true;
      }
      if (node.data == null) {
        return false;
      }

      var data = node.data!;
      var dx = (data.x - x).abs();
      var dy = (data.y - y).abs();
      var dis = dx * dx + dy * dy;
      var r1 = data.size.longestSide / 2;
      var dis2 = r + r1 + space;
      dis2 *= dis2;
      if (dis < dis2) {
        covered = true;
      }
      return covered;
    });
    return covered;
  }
}
