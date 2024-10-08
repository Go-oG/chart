import 'package:e_chart/e_chart.dart';

import '../force.dart';
import '../ffun.dart';

class YForce extends GForce {
  GForceFun _strengthFun = (node, i, list, w, h) {
    return 0.1;
  };
  GForceFun _yFun = (a, b, c, w, h) {
    return 0;
  };
  List<GraphNode> _nodes = [];

  Map<String, num> _strengthMap = {};
  Map<String, num> _yzMap = {};

  YForce([GForceFun? yFun]) {
    if (yFun != null) {
      _yFun = yFun;
    }
  }

  @override
  void initialize(Context context, Graph graph, LCG lcg, double width, double height) {
    super.initialize(context, graph, lcg, width, height);
    _nodes = graph.nodes;
    _initialize();
  }

  void _initialize() {
    _strengthMap = {};
    _yzMap = {};
    each(_nodes, (node, i) {
      var v = _yFun(node, i, _nodes, width, height);
      _yzMap[node.id] = v;
      _strengthMap[node.id] = v.isNaN ? 0 : _strengthFun(node, i, _nodes, width, height);
    });
  }

  @override
  void force([double alpha = 1]) {
    for (var node in _nodes) {
      node.vy += (_yzMap[node.id]! - node.y) * _strengthMap[node.id]! * alpha;
    }
  }

  YForce setStrength(GForceFun fun) {
    _strengthFun = fun;
    _initialize();
    return this;
  }

  YForce setY(GForceFun yFun) {
    _yFun = yFun;
    _initialize();
    return this;
  }
}
