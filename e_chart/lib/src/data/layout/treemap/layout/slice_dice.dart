import 'package:e_chart/e_chart.dart';


class SliceDiceLayout extends HierarchyLayout {
  @override
  void onLayout(Context context, TreeNode data, var option) {
    if (data.deep % 2 == 0) {
      SliceLayout.layoutChildren(option.rect, data.children);
    } else {
      DiceLayout.layoutChildren(option.rect, data.children);
    }
  }
}
