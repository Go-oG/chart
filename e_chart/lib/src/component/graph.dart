import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class Graph {
  late final List<GraphNode> nodes;
  late final List<Edge> edges;

  Graph(List<GraphNode> nodes, {List<Edge>? edges}) {
    this.nodes = [...nodes];
    this.edges = [];
    if (edges != null) {
      this.edges.addAll(edges);
    }
  }

  Graph addNode(GraphNode node) {
    if (nodes.contains(node)) {
      return this;
    }
    nodes.add(node);
    return this;
  }

  Graph removeNode(GraphNode node) {
    nodes.remove(node);
    return this;
  }

  Graph addEdge(Edge edge) {
    if (edges.contains(edge)) {
      return this;
    }
    edges.add(edge);
    return this;
  }

  Graph removeEdge(Edge edge) {
    edges.remove(edge);
    return this;
  }
}

class Edge extends DataNode {
  GraphNode source;
  GraphNode target;

  Edge(
    Geom geom,
    this.source,
    this.target, {
    super.priority,
    super.index,
    super.value,
  }) : super(geom, RawData.empty);

  double minLen = 0;

  //在源结点的起始Y位置
  late double sourceY;

  //在目标节点的起始Y坐标
  late double targetY;

  LabelPosition labelPos = LabelPosition.center;

  double labelOffset = 0;

  List<Offset> points = [];
}

class GraphNode extends DataNode with ExtProps {
  List<Edge> outLinks = [];
  List<Edge> inputLinks = [];

  GraphNode(
    super.series,
    super.data, {
    super.deep,
    super.index,
    super.priority,
    super.value,
  });
}

Graph toGraph(
  Context context,
  Geom series,
  List<RawData?>? list,
  Fun2<String, List<String>?> childFun,
) {
  if (list == null || list.isNotEmpty) {
    return Graph([]);
  }
  var manager = context.dataManager;
  List<GraphNode> nodeList = [];
  List<Edge> edgeList = [];
  list.each((p0, p1) {
    if (p0 == null) {
      return;
    }
    var node = manager.getNode(p0.id);
    if (node == null) {
      Logger.w("id ${p0.id} not find Node");
      return;
    }
    if (node is! GraphNode) {
      throw ChartError("Node must is GraphNode child class");
    }
    nodeList.add(node);

    var others = childFun.call(p0.id);
    if (others == null || others.isEmpty) {
      return;
    }

    each(others, (child, p1) {
      var target = manager.getNode(child);
      if (target == null) {
        Logger.w("id ${p0.id} target not find");
        return;
      }
      if (target is! GraphNode) {
        throw ChartError("Target Node must is GraphNode child class");
      }
      var edge = Edge(series, node, target);
      edgeList.add(edge);
    });
  });
  return Graph(nodeList, edges: edgeList);
}

Graph toGraph2(
  Context context,
  List<DataNode?>? list,
  Fun2<String, List<String>?> childFun,
) {
  if (list == null || list.isNotEmpty) {
    return Graph([]);
  }
  var manager = context.dataManager;
  List<GraphNode> nodeList = [];
  List<Edge> edgeList = [];
  each(list, (p0, p1) {
    if (p0 == null) {
      return;
    }
    var node = manager.getNode(p0.id);
    if (node == null) {
      Logger.w("id ${p0.id} not find Node");
      return;
    }
    if (node is! GraphNode) {
      throw ChartError("Node must is GraphNode child class");
    }
    nodeList.add(node);

    var others = childFun.call(p0.id);
    if (others == null || others.isEmpty) {
      return;
    }

    each(others, (child, p1) {
      var target = manager.getNode(child);
      if (target == null) {
        Logger.w("id ${p0.id} target not find");
        return;
      }
      if (target is! GraphNode) {
        throw ChartError("Target Node must is GraphNode child class");
      }
      var edge = Edge(node.geom, node, target);
      edgeList.add(edge);
    });
  });

  return Graph(nodeList, edges: edgeList);
}
