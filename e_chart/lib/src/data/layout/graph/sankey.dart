import 'dart:math' as m;
import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///布局参考：Ref:https://github.com/d3/d3-sankey/blob/master/src/sankey.js
class SankeyTransform extends EdgeTransform {
  /// 整个视图区域坐标坐标
  double left = 0, top = 0, right = 1, bottom = 1;

  num nodeGap = 0;

  double smooth;

  double nodeWidth;

  int iteratorCount;

  SankeyAlign align;

  NodeSortFun? nodeSort;

  LinkSortFun? linkSort;

  Direction direction;

  SankeyTransform(
    super.childFun, {
    this.nodeWidth = 0.01,
    this.iteratorCount = 6,
    this.nodeSort,
    this.linkSort,
    this.nodeGap = 0,
    this.smooth = 0.5,
    this.direction = Direction.horizontal,
    this.align = const JustifyAlign(),
  });

  @override
  void transform(Context context, double width, double height, Graph? graph) {
    if (graph == null) {
      return;
    }
    left = top = 0;
    right = width;
    bottom = height;
    var dataList = [...graph.nodes];
    var linkList = [...graph.edges];
    dataList = initData(dataList, linkList, 0);

    layoutNode(dataList, linkList);
  }

  void layoutNode(List<GraphNode> nodes, List<Edge> links) {
    _computeNodeLinks(nodes, links);
    _computeNodeValues(nodes);
    _computeNodeDeep(nodes);
    _computeNodeHeights(nodes);
    _computeNodeBreadths(nodes);
    _computeLinkBreadths(nodes);
    _computeLinkPosition(links, nodes);
  }

  /// 计算链接位置
  void _computeLinkPosition(List<Edge> links, List<GraphNode> nodes) {
    for (var node in nodes) {
      node.shape = _buildNode(node);
    }

    for (var link in links) {
      link.shape = _buildLink(link, smooth);
    }
  }

  void computeAreaPath(GeomMix geom, Edge link) {
    Offset sourceTop = Offset(link.source.right, link.sourceY);
    Offset sourceBottom = sourceTop.translate(0, link.width);
    Offset targetTop = Offset(link.target.left, link.targetY);
    Offset targetBottom = targetTop.translate(0, link.width);
    link.shape = Area([sourceTop, targetTop], [sourceBottom, targetBottom], upSmooth: smooth, downSmooth: smooth);
  }

  void _computeNodeLinks(List<GraphNode> nodes, List<Edge> links) {
    nodes.each((p0, p1) {
      p0.index = p1;
    });
    links.each((link, i) {
      link.index = i;
      link.source.outLinks.add(link);
      link.target.inputLinks.add(link);
    });

    if (linkSort != null) {
      for (var ele in nodes) {
        ele.outLinks.sort(linkSort);
        ele.inputLinks.sort(linkSort);
      }
    }
  }

  ///计算节点数值(统计流入和流出取最大值)
  void _computeNodeValues(List<GraphNode> nodes) {
    for (var node in nodes) {
      if (node.fixValue != null) {
        node.value = node.fixValue!;
        continue;
      }
      num sv = sumBy(node.inputLinks, (p0) => p0.value);
      num tv = sumBy(node.outLinks, (p0) => p0.value);
      node.value = max(sv, tv).toDouble();
    }
  }

  ///计算节点图深度
  ///同时判断是否存在环路
  void _computeNodeDeep(List<GraphNode> nodes) {
    int n = nodes.length;
    Set<GraphNode> current = Set.from(nodes);
    Set<GraphNode> next = {};
    int x = 0;
    while (current.isNotEmpty) {
      for (var node in current) {
        node.deep = x;

        for (var element in node.outLinks) {
          next.add(element.target);
        }
      }
      if (++x > n) {
        throw ChartError("circular link");
      }
      current = next;
      next = {};
    }
  }

  ///计算节点图高度(同时判断是否存在环路)
  void _computeNodeHeights(List<GraphNode> nodes) {
    int n = nodes.length;
    Set<GraphNode> current = Set.from(nodes);
    Set<GraphNode> next = {};
    int x = 0;
    while (current.isNotEmpty) {
      for (var node in current) {
        node.treeHeight = x;
        for (var link in node.inputLinks) {
          next.add(link.source);
        }
      }
      x += 1;
      if (x > n) throw ChartError("circular link");
      current = next;
      next = {};
    }
  }

  ///计算节点层次结构用于确定横向坐标
  List<List<GraphNode>> _computeNodeLayers(List<GraphNode> nodes) {
    int x = maxBy<GraphNode>(nodes, (p0) => p0.deep).deep + 1;
    double kx = (right - left - nodeWidth) / (x - 1);

    List<List<GraphNode>> columns = List.generate(x, (index) => []);

    for (var node in nodes) {
      int i = max(0, min(x - 1, align.align(node, x).floor()));
      node.layer = i;
      var leftOff = left + i * kx;
      node.x = leftOff + node.width / 2;
      columns[i].add(node);
    }
    if (nodeSort != null) {
      for (var column in columns) {
        column.sort(nodeSort);
      }
    }

    return columns;
  }

  ///初始化给定列数的每个节点的高度
  void _initializeNodeBreadths(List<List<GraphNode>> columns) {
    //计算比例尺
    double ky = minBy2<List<GraphNode>>(columns, (c) {
      var v = (bottom - top - (c.length - 1) * nodeGap);
      var sv = sumBy<GraphNode>(c, (p0) => p0.value);
      return v / sv;
    }).toDouble();
    if (ky.isNaN || ky.isInfinite) {
      Logger.w("比例尺计算异常 ky=$ky,将固定比例尺");
      ky = 0.3;
    }

    for (var nodes in columns) {
      double y = top;
      for (var node in nodes) {
        node.height = node.value * ky;
        node.y = y + node.height / 2;
        y = node.bottom + nodeGap;
        for (var link in node.outLinks) {
          link.width = link.value * ky;
        }
      }

      y = (bottom - y + nodeGap) / (nodes.length + 1);
      each(nodes, (node, i) {
        var t = node.top + y * (i + 1);
        var b = node.bottom + y * (i + 1);
        node.height = b - t;
        node.y = t + (node.height / 2);
      });
      _reorderLinks(nodes);
    }
  }

  ///计算节点高度(多次迭代)
  void _computeNodeBreadths(List<GraphNode> nodes) {
    List<List<GraphNode>> columns = _computeNodeLayers(nodes);

    ///计算节点间距(目前可能不需要，因为series已经定义了)
    num dy = 8;
    nodeGap = m.min(dy, (bottom - top) / (maxBy2(columns, (c) => c.length) - 1));

    _initializeNodeBreadths(columns);
    int iterations = iteratorCount;
    for (int i = 0; i < iterations; ++i) {
      double alpha = m.pow(0.99, i).toDouble();
      double beta = m.max(1 - alpha, (i + 1) / iterations);
      _relaxRightToLeft(columns, alpha, beta);
      _relaxLeftToRight(columns, alpha, beta);
    }
  }

  /// 根据传入目标链接重新定位每个节点
  void _relaxLeftToRight(List<List<GraphNode>> columns, double alpha, double beta) {
    each(columns, (column, i) {
      for (var target in column) {
        num y = 0;
        num w = 0;
        for (var link in target.inputLinks) {
          num v = link.value * (target.layer - link.source.layer);
          y += _targetTop(link.source, target) * v;
          w += v;
        }
        if (w <= 0) {
          continue;
        }
        double dy = (y / w - target.top) * alpha;

        target.height += 2 * dy;

        _reorderNodeLinks(target);
      }
      if (nodeSort == null) {
        column.sort(_ascBreadth);
      }
      _resolveCollisions(column, beta);
    });
  }

  ///根据传入目标链接重新定位每个节点
  void _relaxRightToLeft(List<List<GraphNode>> columns, double alpha, double beta) {
    for (int n = columns.length, i = n - 2; i >= 0; --i) {
      var column = columns[i];
      for (var source in column) {
        double y = 0;
        double w = 0;
        for (var link in source.outLinks) {
          num v = link.value * (link.target.layer - source.layer);
          y += _sourceTop(source, link.target) * v;
          w += v;
        }
        if (w <= 0) {
          continue;
        }
        double dy = (y / w - source.top) * alpha;
        source.height += 2 * dy;
        _reorderNodeLinks(source);
      }
      if (nodeSort == null) {
        column.sort(_ascBreadth);
      }
      _resolveCollisions(column, beta);
    }
  }

  void _resolveCollisions(List<GraphNode> nodes, double alpha) {
    if (nodes.isEmpty) {
      return;
    }
    int i = nodes.length >> 1;

    /// 算数右移
    var subject = nodes[i];
    _resolveCollisionsBottomToTop(nodes, subject.top - nodeGap, i - 1, alpha);
    _resolveCollisionsTopToBottom(nodes, subject.bottom + nodeGap, i + 1, alpha);
    _resolveCollisionsBottomToTop(nodes, bottom, nodes.length - 1, alpha);
    _resolveCollisionsTopToBottom(nodes, top, 0, alpha);
  }

  ///向下推任何重叠的节点
  void _resolveCollisionsTopToBottom(List<GraphNode> nodes, double y, int arrayIndex, double alpha) {
    for (; arrayIndex < nodes.length; ++arrayIndex) {
      var node = nodes[arrayIndex];
      var dy = (y - node.top) * alpha;
      if (dy > 1e-6) {
        node.height += 2 * dy;
      }
      y = node.bottom + nodeGap;
    }
  }

  ///向上推任何重叠的节点。
  void _resolveCollisionsBottomToTop(List<GraphNode> nodes, double y, int arrayIndex, double alpha) {
    for (; arrayIndex >= 0; --arrayIndex) {
      var node = nodes[arrayIndex];
      double dy = (node.bottom - y) * alpha;
      if (dy > 1e-6) {
        node.height -= 2 * dy;
      }
      y = node.top - nodeGap;
    }
  }

  void _reorderNodeLinks(GraphNode node) {
    if (linkSort != null) {
      return;
    }

    for (var link in node.inputLinks) {
      link.source.outLinks.sort(_ascTargetBreadth);
    }
    for (var link in node.outLinks) {
      link.target.inputLinks.sort(_ascSourceBreadth);
    }
  }

  void _reorderLinks(List<GraphNode> nodes) {
    if (linkSort != null) {
      return;
    }
    for (var node in nodes) {
      node.outLinks.sort(_ascTargetBreadth);
      node.inputLinks.sort(_ascSourceBreadth);
    }
  }

  ///返回target.top，它将生成从源到目标的理想链接
  double _targetTop(GraphNode source, GraphNode target) {
    double y = source.top - (source.outLinks.length - 1) * nodeGap / 2;
    for (var link in source.outLinks) {
      if (link.target == target) {
        break;
      }
      y += link.width + nodeGap;
    }

    for (var link in target.inputLinks) {
      if (link.source == source) {
        break;
      }
      y -= link.width;
    }
    return y;
  }

  ///返回source.top，它将生成从源到目标的理想链接
  double _sourceTop(GraphNode source, GraphNode target) {
    double y = target.top - (target.inputLinks.length - 1) * nodeGap / 2;
    for (var link in target.inputLinks) {
      if (link.source == source) {
        break;
      }
      y += link.width + nodeGap;
    }
    for (var link in source.outLinks) {
      if (link.target == target) {
        break;
      }
      y -= link.width;
    }
    return y;
  }

  List<GraphNode> initData(List<GraphNode> dataList, List<Edge> links, double nodeWidth) {
    Map<String, GraphNode> dataMap = {};
    each(dataList, (p0, p1) {
      dataMap[p0.id] = p0;
      p0.index = p1;
    });
    int index = dataMap.length;

    each(links, (link, p1) {
      link.index = p1;
      var source = link.source;
      if (dataMap.containsKey(source.id)) {
        link.source = dataMap[source.id]!;
      } else {
        dataMap[source.id] = source;
        source.index = index;
        index++;
      }
      var target = link.target;
      if (dataMap.containsKey(target.id)) {
        link.target = dataMap[target.id]!;
      } else {
        dataMap[target.id] = target;
        target.index = index;
        index++;
      }
    });
    return List.from(dataMap.values);
  }

  List<Edge> getDataInLink(GraphNode data) => data.inputLinks;

  List<Edge> getDataOutLink(GraphNode data) => data.outLinks;

  GraphNode getLinkSource(Edge link) => link.source;

  GraphNode getLinkTarget(Edge link) => link.target;
}

extension _SankeyExt on GraphNode {
  int get layer {
    return getAttr2("sankey_layer")!;
  }

  set layer(int l) {
    putAttr("sankey_layer", l);
  }
}

CShape _buildNode(DataNode node) {
  return CRect(left: node.left, top: node.top, right: node.right, bottom: node.bottom);
}

CShape _buildLink(DataNode node, double smooth) {
  var link = node as Edge;
  Offset sourceTop = Offset(link.source.right, link.sourceY);
  Offset sourceBottom = sourceTop.translate(0, link.width);
  Offset targetTop = Offset(link.target.left, link.targetY);
  Offset targetBottom = targetTop.translate(0, link.width);
  return Area([sourceTop, targetTop], [sourceBottom, targetBottom], upSmooth: smooth, downSmooth: smooth);
}

int _ascSourceBreadth(Edge a, Edge b) {
  int ab = _ascBreadth(a.source, b.source);
  if (ab != 0) {
    return ab;
  }
  return (a.index - b.index);
}

int _ascTargetBreadth(Edge a, Edge b) {
  int ab = _ascBreadth(a.target, b.target);
  if (ab != 0) {
    return ab;
  }
  return (a.index - b.index);
}

int _ascBreadth(GraphNode a, GraphNode b) {
  return a.top.compareTo(b.top);
}

void _computeLinkBreadths(List<GraphNode> nodes) {
  for (var node in nodes) {
    num y0 = node.top;

    for (var link in node.outLinks) {
      link.sourceY = y0.toDouble();
      y0 += link.width;
    }
    double y1 = node.top;

    for (var link in node.inputLinks) {
      link.targetY = y1;
      y1 += link.width;
    }
  }
}

abstract class SankeyAlign {
  const SankeyAlign();

  num align(GraphNode node, int n);
}

class LeftAlign extends SankeyAlign {
  const LeftAlign();

  @override
  num align(GraphNode node, int n) {
    return node.deep;
  }
}

class RightAlign extends SankeyAlign {
  const RightAlign();

  @override
  num align(GraphNode node, int n) {
    return (n - 1 - node.treeHeight);
  }
}

class JustifyAlign extends SankeyAlign {
  const JustifyAlign();

  @override
  num align(GraphNode node, int n) {
    if (node.outLinks.isEmpty) {
      return n - 1;
    }
    return node.deep;
  }
}

class CenterAlign extends SankeyAlign {
  const CenterAlign();

  @override
  num align(GraphNode node, int n) {
    if (node.inputLinks.isNotEmpty) {
      return node.deep;
    }
    if (node.outLinks.isNotEmpty) {
      int deep = node.outLinks[0].target.deep;
      for (var element in node.outLinks) {
        if (element.target.deep < deep) {
          deep = element.target.deep;
        }
      }
      return deep - 1;
    }
    return 0;
  }
}
