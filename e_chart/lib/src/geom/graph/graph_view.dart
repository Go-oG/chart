import 'package:e_chart/e_chart.dart';

class GraphView extends AnimateGeomView<GraphSeries> {
  GraphView(super.context, super.series);
  List<Edge> edgeList = [];

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    saveOldNodeSet();
    var graph = geom.getGraph(context);
    List<DataNode> list = List.from(graph.nodes);
    List<Edge> edgeList = List.from(graph.edges);
    geom.transform.transform(context, width, height, graph);
    this.edgeList = edgeList;
    setNodeSet(list);
  }

  @override
  void onDraw(Canvas2 canvas) {
    for (var edge in edgeList) {
      edge.shape.render(canvas, mPaint, LineStyle.empty);
    }
    super.onDraw(canvas);
  }

  @override
  void onLayoutNodeList(List<DataNode> nodeList) {
  }
}
