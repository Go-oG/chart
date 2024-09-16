import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class GForceTransform extends GTransform {
  final List<GForce> forces;
  List<SNumber> center;
  double alpha;
  double alphaMin;
  double? alphaDecay;
  double alphaTarget;
  double velocityDecay;
  bool optPerformance;
  GForceSimulation? _simulation;

  GForceTransform(
    this.forces,
    super.childFun, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.alpha = 1,
    this.alphaMin = 0.001,
    this.alphaDecay,
    this.alphaTarget = 0,
    this.velocityDecay = 0.1,
    this.optPerformance = false,
    super.nodeSpaceFun,
    super.sort,
  });

  GForceTransform start() {
    _simulation?.start();
    return this;
  }

  GForceTransform restart() {
    _simulation?.restart();
    return this;
  }

  Offset _center = Offset.zero;

  @override
  Offset getTranslation() => _center;

  @override
  void transform(Context context, double width, double height, Graph? graph) {
    if (graph == null || graph.nodes.isEmpty) {
      return;
    }
    _center = Offset(center[0].convert(width), center[1].convert(height));
    if (_simulation == null) {
      _simulation = _initSimulation(context, graph, width, height);
      _simulation?.addListener((t) {
        notifyLayoutUpdate();
      });
      _simulation?.onEnd = () {
        notifyLayoutEnd();
      };
    }
    start();
  }

  @override
  void stopLayout() {
    _simulation?.stop();
    _simulation?.dispose();
    _simulation = null;
    super.stopLayout();
  }

  @override
  void dispose() {
    _simulation?.dispose();
    _simulation = null;
    super.dispose();
  }

  @override
  bool get isDynamicLayout => true;

  GForceSimulation _initSimulation(Context context, Graph graph, double width, double height) {
    GForceSimulation simulation = GForceSimulation(context, graph);
    simulation.optPerformance = optPerformance;
    simulation.width = width;
    simulation.height = height;
    simulation.alpha(alpha);
    simulation.alphaMin(alphaMin);
    simulation.alphaTarget(alphaTarget);
    simulation.velocityDecay(velocityDecay);
    if (alphaDecay != null) {
      simulation.alphaDecay(alphaDecay!);
    }
    for (var f in forces) {
      simulation.addForce(f);
    }
    return simulation;
  }
}
