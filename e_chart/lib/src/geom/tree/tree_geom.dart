import 'package:e_chart/e_chart.dart';

class TreeGeom extends BaseTreeGeom {
  HierarchyTransform transform;
  List<SNumber> center;

  TreeGeom(
    super.dataSet,
    super.parentFun,
    super.childFun,
    this.transform, {
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
}
