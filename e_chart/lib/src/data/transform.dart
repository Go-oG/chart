import 'dart:async';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

mixin class TransformMix {
  final List<DataTransform> _dataTransformList = [];
  final List<LayoutTransform> _layoutTransformList = [];

  void addDataTransform(DataTransform transform) {
    _dataTransformList.add(transform);
  }

  void removeDataTransform(DataTransform transform) {
    _dataTransformList.remove(transform);
  }

  void addLayoutTransform(LayoutTransform transform) {
    _layoutTransformList.add(transform);
  }

  void removeLayoutTransform(LayoutTransform transform) {
    _layoutTransformList.remove(transform);
  }

  void clearDataTransform() {
    _dataTransformList.clear();
  }

  void clearLayoutTransform() {
    _layoutTransformList.clear();
  }

  List<DataTransform> get dataTransformList => _dataTransformList;

  List<LayoutTransform> get layoutTransformList => _layoutTransformList;
}

abstract class DataTransform extends Disposable {
  ///在转换原始数据之前被调用
  ///返回的原始数据会被传递给[onAfterConvertRawData]方法
  ///在此之后原始数据将被冻结，原始数据值将无法修改
  List<RawData> onBeforeConvertRawData(Geom geom, List<RawData> dataSet) {
    return dataSet;
  }

  ///在原始数据被转换完成后调用
  ///该方法之后的所有数据取值操作都应该使用DataNode的属性
  void onAfterConvertRawData(Geom geom, List<DataNode> nodeList) {}

  ///在计算极值之前被调用
  ///[nodeList] 是全部数据节点集合
  void onBeforeComputeExtreme2(Iterable<DataNode> nodeList, Map<String, Coord> coordMap) {}

  ///在创建刻度之前被调用
  void onBeforeBuildScale(
      Iterable<DataNode> nodeList, Map<String, Coord> coordMap, Map<String, Map<AxisDim, DataExtreme>> extremeMap) {}

  ///在创建刻度之后被调用
  void onAfterBuildScale(Context context, Geom geom, List<DataNode> nodeList) {}

}

abstract class BaseDataTransform extends DataTransform {
  @override
  List<RawData> onBeforeConvertRawData(Geom geom, List<RawData> dataSet) {
    return transform(dataSet);
  }

  List<RawData> transform(List<RawData> input);
}

abstract class LayoutTransform {
  ViewNotifier? _viewNotifier;

  set notifier(ViewNotifier? notifier) {
    _viewNotifier = notifier;
  }

  void notifyLayoutEnd() {
    _viewNotifier?.notifyLayoutEnd();
  }

  void notifyLayoutUpdate() {
    _viewNotifier?.notifyLayoutUpdate();
  }

  bool get isDynamicLayout => false;

  ///正常布局之前
  FutureOr<void> onLayout(Context context, GeomView view, ViewNotifier? notifier, List<DataNode> nodeList) {}

  void dispose() {}
}

abstract class PointTransform extends LayoutTransform {
  @override
  FutureOr<void> onLayout(Context context, ChartView view, ViewNotifier? notifier, List<DataNode> nodeList) async {
    this.notifier = notifier;
    if (nodeList.isEmpty) {
      return;
    }
    await transform(context, view.width, view.height, nodeList);
  }

  FutureOr<void> transform(Context context, double width, double height, List<DataNode> nodeList);
}

abstract class EdgeTransform extends LayoutTransform {
  Fun2<String, List<String>?> childFun;

  EdgeTransform(this.childFun);

  Graph? _graph;

  Graph? get graph => _graph;

  @override
  FutureOr<void> onLayout(Context context, ChartView view, ViewNotifier? notifier, List<DataNode> nodeList) async {
    this.notifier = notifier;
    if (nodeList.isEmpty) {
      return;
    }
    var gg = toGraph2(context, nodeList, childFun);
    _graph = gg;
    await transform(context, view.width, view.height, gg);
  }

  FutureOr<void> transform(Context context, double width, double height, Graph graph);
}

abstract class HierarchyTransform extends LayoutTransform {
  Fun2<String, String?> parentFun;
  Fun2<String, List<String>?> childFun;
  Fun2<RawData, double>? valueFun;
  HierarchyLayout layout = HierarchyLayout();

  HierarchyTransform(
    this.parentFun,
    this.childFun, {
    this.valueFun,
    HierarchyLayout? layout,
  }) {
    if (layout != null) {
      this.layout = layout;
    }
  }

  TreeNode? _root;

  TreeNode? get root => _root;

  @override
  FutureOr<void> onLayout(Context context, ChartView view, ViewNotifier? notifier, List<DataNode> nodeList) async {
    this.notifier = notifier;
    if (nodeList.isEmpty) {
      return;
    }
    var tt = toTree2(context, nodeList, parentFun, childFun);
    _root = tt;
    if (tt == null) {
      return;
    }
    await transform(context, view.width, view.height, tt);
  }

  FutureOr<void> transform(Context context, double width, double height, TreeNode root);

  void initData(TreeNode root) {
    int c = 0;
    root.each((node, index, startNode) {
      node.index = c;
      c++;
      return false;
    });

    root.sum((p0) => p0.value);
    root.computeHeight();
    int maxDeep = root.treeHeight;
    root.each((node, index, startNode) {
      node.maxDeep = maxDeep;
      return false;
    });
  }
}

abstract class TreeMapTransform extends HierarchyTransform {
  TreeMapTransform(
    super.parentFun,
    super.childFun, {
    super.layout,
    super.valueFun,
  });

  ///返回显示的深度
  int get showDepth;
}

class HierarchyLayout extends Disposable {
  void onLayout(Context context, TreeNode data, covariant HierarchyOption option) {}
}

class HierarchyOption with ExtProps {
  final Rect rect;
  final Offset center;

  HierarchyOption(this.rect, [this.center = Offset.zero]);

  double get width => rect.width;

  double get height => rect.height;
}
