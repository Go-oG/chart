import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///树形视图相关的
class TreeMapGeom extends BaseTreeGeom {
  static final Command commandBack = Command(11);
  TreeMapTransform transform;

  ///标签文字对齐位置
  Offset labelPadding;

  TreeMapGeom(
    super.dataSet,
    super.parentFun,
    super.childFun,
    this.transform, {
    super.enableDrag,
    this.labelPadding = const Offset(2, 2),
    super.layoutParams,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
  });

  @override
  ChartView? toView(Context context) {
    return TreeMapView(context, this);
  }

  @override
  bool get useParentValue => false;

  @override
  GeomType get geomType => GeomType.treeMap;
}
