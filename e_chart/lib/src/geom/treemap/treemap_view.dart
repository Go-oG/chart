import 'package:e_chart/e_chart.dart';

/// 矩形树图
class TreeMapView extends AnimateGeomView<TreeMapGeom> {
  TreeMapView(super.context, super.geom);
  TreeNode? rootNode;

  @override
  void onCreate() {
    super.onCreate();
    enableGesture(GestureType.drag, geom.enableDrag);
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    var rootNode = geom.getTree(context);
    if (rootNode == null) {
      return;
    }
    geom.transform.transform(context, width, height, rootNode);
    this.rootNode = rootNode;
  }

  @override
  void onDraw(Canvas2 canvas) {
    var levelList = rootNode?.levelEach(geom.transform.showDepth);
    if (levelList == null) {
      return;
    }
    for (var list in levelList) {
      for (var item in list) {
        item.shape.render(canvas, mPaint, AreaStyle.empty);
      }
    }
  }

  @override
  void onLayoutPositionAndSize(List<DataNode> nodeList) {
    throw UnsupportedError("");
  }
}
