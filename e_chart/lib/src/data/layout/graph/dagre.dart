import 'package:flutter/widgets.dart';
import 'package:e_chart/e_chart.dart';
import 'package:dart_dagre/dart_dagre.dart' as dg;

///层次布局
class GDagreTransform extends GTransform {
  final bool multiGraph;
  final bool compoundGraph;
  final bool directedGraph;
  final dg.DagreConfig config;

  GDagreTransform(
    this.config,
    super.childFun, {
    this.multiGraph = false,
    this.compoundGraph = true,
    this.directedGraph = true,
    super.nodeSpaceFun,
    super.sort,
  });

  @override
  void transform(Context context, double width, double height, Graph? graph) {
    if (graph == null || graph.nodes.isEmpty) {
      return;
    }

    DagreGraph layoutGraph = DagreGraph();
    Map<String, GraphNode> nodeMap = {};
    Map<String, Edge> edgeMap = {};
    for (var ele in graph.nodes) {
      nodeMap[ele.id] = ele;
      Size size = ele.size;
      DagreNode node = DagreNode(ele.id, width: size.width, height: size.height);
      layoutGraph.addNode(node);
    }

    for (var e in graph.edges) {
      edgeMap[e.id]=e;
      var source = nodeMap[e.source.id];
      if (source == null) {
        throw ChartError('无法找到Source');
      }
      var target = nodeMap[e.target.id];
      if (target == null) {
        throw ChartError('无法找到Target');
      }
      var edge = DagreEdge(
        source.id,
        target.id,
        minLen: e.minLen,
        weight: e.weight,
        labelOffset: e.labelOffset,
        width: e.width,
        height: e.height,
        labelPos: e.labelPos,
        id: e.id,
      );
      layoutGraph.addEdge(edge);
    }

    DagreResult result = dg.layout(layoutGraph, config);
    layoutGraph.nodes.each((e,i){
      var node = nodeMap[e.id]!;
      var p=e.position!;
      var center=p.center;
      node.x = center.dx;
      node.y = center.dy;
      node.width = p.width;
      node.height = p.height;
    });
    layoutGraph.edges.each((e,i){
      var edge=edgeMap[e.id]!;
      edge.points = e.points;
    });
    graph.width=result.graphWidth;
    graph.height=result.graphHeight;

  }
}
