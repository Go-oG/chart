import 'dart:ui';
import 'view.dart';
import '../../data/state.dart';

abstract class ViewParent {
  void requestLayout();

  bool isLayoutRequested();

  void redrawParentCaches();

  void onDescendantInvalidated(ChartView child, ChartView target);

  void requestChildFocus(ChartView child, ChartView focused);

  void recomputeViewAttributes(ChartView child);

  void clearChildFocus(ChartView child);

  void clearFocus();

  void unFocus(ChartView focused);

  bool getChildVisibleRect(ChartView child, Rect r, Offset offset);

  ///更改孩子到最顶部(最后绘制)
  void changeChildToFront(ChartView child);

  void childHasTransientStateChanged(ChartView child, bool hasTransientState);

  void childVisibilityChange(ChartView child, ViewVisibility old);
}
