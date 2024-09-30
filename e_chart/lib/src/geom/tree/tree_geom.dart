import 'package:e_chart/e_chart.dart';

class TreeGeom extends BaseTreeGeom {
  List<SNumber> center;

  TreeGeom(
    super.dataSet,
    super.parentFun,
    super.childFun, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    super.animation,
    super.backgroundColor,
    super.clip,
    super.id,
    super.layoutParams,
    super.tooltip,
  });

  @override
  ChartView? toView(Context context) {
    return TreeView(context, this);
  }

  @override
  GeomType get geomType => GeomType.tree;

  @override
  void addLayoutTransform(LayoutTransform transform) {
    if (transform is! HierarchyTransform) {
      throw UnsupportedError("only support HierarchyTransform");
    }
    super.addLayoutTransform(transform);
  }
}
