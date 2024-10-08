import 'package:e_chart/e_chart.dart';
import '../force.dart';
import '../ffun.dart';

class XForce extends GForce {
  GForceFun _xFun = (a, b, c, w, h) {
    return 0;
  };

  GForceFun _strengthFun = (node, i, list, w, h) {
    return 0.1;
  };
  List<GraphNode> _nodes = [];
  Map<String, num> _strengthMap = {};
  Map<String, num> _xzMap = {};

  XForce([GForceFun? xFun]) {
    if (xFun != null) {
      _xFun = xFun;
    }
  }

  @override
  void initialize(Context context, Graph graph, lcg, double width, double height) {
    super.initialize(context, graph, lcg, width, height);
    _nodes = graph.nodes;
    _initialize();
  }

  void _initialize() {
    _strengthMap = {};
    _xzMap = {};
    each(_nodes, (node, i) {
      var v = _xFun(node, i, _nodes, width, height);
      _xzMap[node.id] = v;
      _strengthMap[node.id] = v.isNaN ? 0 : _strengthFun(node, i, _nodes, width, height);
    });
  }

  @override
  void force([double alpha = 1]) {
    for (var node in _nodes) {
      node.vx += (_xzMap[node.id]! - node.x) * _strengthMap[node.id]! * alpha;
    }
  }

  XForce setStrength(GForceFun fun) {
    _strengthFun = fun;
    _initialize();
    return this;
  }

  XForce setX(GForceFun xFun) {
    _xFun = xFun;
    _initialize();
    return this;
  }
}
