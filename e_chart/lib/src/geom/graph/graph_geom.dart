import 'package:e_chart/e_chart.dart';

class GraphSeries extends Geom {
  Fun2<String, List<String>?> childFun;
  Fun2<RawData, double> valueFun;
  EdgeTransform transform;

  GraphSeries(
    super.dataSet,
    super.scope,
    this.transform,
    this.childFun,
    this.valueFun, {
    super.animation,
    super.backgroundColor,
    super.clip,
    super.id,
    super.layoutParams,
    super.tooltip,
    super.cacheLayer,
  });

  @override
  GeomType get geomType => GeomType.graph;

  Graph? _graph;

  Graph getGraph(Context context) {
    if (_graph != null) {
      return _graph!;
    }
    return _graph = toGraph(context, this, dataSet, childFun);
  }

  @override
  ChartView? toView(Context context) {
    return GraphView(context, this);
  }

  @override
  DataNode toNode(RawData data) {
    var node = GraphNode(this, data);
    node.value = valueFun.call(data);
    return node;
  }

  @override
  void notifyUpdateData() {
    _graph = null;
    super.notifyUpdateData();
  }

  @override
  void notifyConfigChange() {
    _graph = null;
    super.notifyConfigChange();
  }
}
