
import '../component/graph.dart';

enum Sort { none, desc, asc }

enum Order { asc, desc }

abstract class GraphSort {
  void sort(List<GraphNode> nodeList);
}

abstract class EdgeSort {
  void sort(List<Edge> edgeList);
}

typedef LinkSortFun = int Function(Edge, Edge);

typedef NodeSortFun = int Function(GraphNode, GraphNode);
