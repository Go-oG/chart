import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///抽象的转换器
abstract class ChartTransform extends Disposable {
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

  ///如果需要拦截布局则返回true
  /// 当返回true时，则不会执行正常的布局流程，而是直接调用[onBuildNodeShape]方法
  /// 否则会先后调用 [onBeforeLayout], [onAfterLayout]
  /// 通常只有在一些复杂布局 例如 图 树 时才会拦截布局流程
  bool onInterceptLayout(
      Context context, ViewNotifier? notifier, List<DataNode> nodeList, double width, double height) {
    return false;
  }

  void onBuildNodeShape(List<DataNode> nodeList) {}

  ///正常布局之前
  void onBeforeLayout(Context context, ViewNotifier? notifier, List<DataNode> nodeList, double width, double height) {}

  ///正常布局之后
  void onAfterLayout(Context context, List<DataNode> nodeList, double width, double height) {}
}

abstract class DataTransform extends ChartTransform {
  @override
  List<RawData> onBeforeConvertRawData(Geom geom, List<RawData> dataSet) {
    return transform(dataSet);
  }

  List<RawData> transform(List<RawData> input);
}

abstract class LayoutTransform extends ChartTransform {
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
}

abstract class PointTransform extends LayoutTransform {
  @override
  bool onBeforeLayout(Context context, ViewNotifier? notifier, List<DataNode> nodeList, double width, double height) {
    if (nodeList.isEmpty) {
      return true;
    }
    this.notifier = notifier;
    transform(context, width, height, nodeList);
    return true;
  }

  void transform(Context context, double width, double height, List<DataNode> nodeList);
}

abstract class EdgeTransform extends LayoutTransform {
  Fun2<String, List<String>?> childFun;

  EdgeTransform(this.childFun);

  Graph? _graph;

  Graph? get graph => _graph;

  @override
  bool onBeforeLayout(Context context, ViewNotifier? notifier, List<DataNode> nodeList, double width, double height) {
    if (nodeList.isEmpty) {
      return true;
    }
    this.notifier = notifier;
    var gg = toGraph2(context, nodeList, childFun);
    _graph = gg;
    transform(context, width, height, gg);
    return true;
  }

  void transform(Context context, double width, double height, Graph graph);
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
  bool onBeforeLayout(Context context, ViewNotifier? notifier, List<DataNode> nodeList, double width, double height) {
    if (nodeList.isEmpty) {
      return true;
    }
    this.notifier = notifier;
    var tt = toTree2(context, nodeList, parentFun, childFun);
    if (tt == null) {
      return true;
    }
    transform(context, width, height, tt);
    return true;
  }

  void transform(Context context, double width, double height, TreeNode root);

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
