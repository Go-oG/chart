import 'package:e_chart/e_chart.dart';

abstract class BaseTreeGeom extends Geom {
  Fun2<String, String?> parentFun;
  Fun2<String, List<String>?> childFun;

  bool enableDrag;

  BaseTreeGeom(
    List<RawData> dataSet,
    this.parentFun,
    this.childFun, {
    this.enableDrag = true,
    super.layoutParams,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
  }) : super(dataSet, randomId());

  TreeNode? _tree;

  TreeNode? getTree(Context context) {
    var tree = _tree;
    if (tree != null) {
      return tree;
    }
    tree = toTree(context, this, dataSet, parentFun, childFun);
    if (tree != null) {
      computeTree(tree, useParent: useParentValue);
    }
    _tree = tree;
    return _tree;
  }

  bool get useParentValue => true;

  @override
  DataNode toNode(RawData data) {
    var node = TreeNode(this, data, null, []);
    node.value = data.get(firstPos.field, double.nan);
    return node;
  }

  @override
  void notifyConfigChange() {
    _tree = null;
    super.notifyConfigChange();
  }

  @override
  void notifyUpdateData() {
    _tree = null;
    super.notifyUpdateData();
  }

  @override
  void dispose() {
    _tree = null;
    super.dispose();
  }
}
