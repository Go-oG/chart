import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class GTransform extends EdgeTransform {
  Fun2<List<GraphNode>, Map<GraphNode, num>>? sort;
  Fun2<GraphNode, num>? nodeSpaceFun;

  GTransform(super.childFun, {this.nodeSpaceFun, this.sort});

  void stopLayout() {}

  Offset getTranslation() => Offset.zero;

  ///获取节点间距
  num getNodeSpace(GraphNode node) {
    return nodeSpaceFun?.call(node) ?? 8;
  }

  void sortNode(Graph graph, List<GraphNode> list, [bool asc = false]) {
    if (sort == null) {
      return;
    }
    Map<GraphNode, num> sortMap = sort!.call(list);
    list.sort((a, b) {
      num av = sortMap[a] ?? 0;
      num bv = sortMap[b] ?? 0;
      if (asc) {
        return av.compareTo(bv);
      } else {
        return bv.compareTo(av);
      }
    });
  }
}
