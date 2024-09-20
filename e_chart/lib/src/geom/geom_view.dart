import 'dart:async';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

///基础的GeomView
///主要负责管理和更新数据节点
abstract class BaseGeomView<T extends Geom> extends GestureView with ViewEventMix {
  T? _geom;

  T get geom => _geom!;

  BaseGeomView(super.context, T geom) {
    _geom = geom;
    layoutParams = geom.layoutParams;
  }

  ///============其它方法或字段===================
  @protected
  final ViewNotifier viewNotifier = ViewNotifier();

  ///存储当前所有节点的分布情况
  @protected
  late final RBush<DataNode> rBush = RBush(
    (p0) => getNodeBound(p0).left,
    (p0) => getNodeBound(p0).top,
    (p0) => getNodeBound(p0).right,
    (p0) => getNodeBound(p0).bottom,
  );

  ///存储复合shape例如 line path等需要多个数据共同构建的的CShape
  ///其它单个数据对应的自身CShape 由节点自身存储
  @protected
  List<CombineShape> combineShapeList = [];

  ///存储当前View下所有的数据节点
  @protected
  final DataNodeSet nodeSet = DataNodeSet();

  ///存储当前显示中的节点
  @protected
  final DataNodeSet showNodeSet = DataNodeSet();

  ///存储数据集改变前的数据
  ///用于实现动画更新效果
  @protected
  final DataNodeSet preNodeSet = DataNodeSet();

  DataNode? _statusNode;

  @override
  void onCreate() {
    super.onCreate();
    viewNotifier.addListener((v) {
      var code = v.code;
      if (code == Command.layoutEnd.code || code == Command.layoutUpdate.code || code == Command.invalidate.code) {
        repaint();
      } else if (code == Command.configChange.code || code == Command.updateData.code) {
        requestLayout();
      }
    });
    bindGeom(geom);
    List<DataNode> nl = [];
    var manager = context.dataManager;
    for (var data in geom.dataSet) {
      var node = manager.getNode(data.id);
      if (node == null) {
        continue;
      }
      nl.add(node);
    }
    setNodeSet(nl);
  }

  @override
  void onDispose() {
    unBindGeom();
    _geom?.clearListener();
    _geom = null;
    super.onDispose();
  }

  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    setMeasuredDimension(widthSpec.size, heightSpec.size);
  }

  @override
  void onDrawBackground(Canvas2 canvas) {
    Color? color = geom.backgroundColor;
    if (color != null) {
      mPaint.reset();
      mPaint.color = color;
      mPaint.style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(-left, -top, width, height), mPaint);
    }
  }

  @override
  void onDraw(Canvas2 canvas) {
    super.onDraw(canvas);
    for (var node in showNodeSet.nodeList) {
      node.shape.render(canvas, mPaint, AreaStyle(color: randomColor()));
    }
  }

  @override
  void onDragMove(Offset local, Offset global, Offset diff) {
    super.onDragMove(local, global, diff);
    updateShowNodeSet();
    repaint();
  }

  @override
  void onClick(Offset local, Offset global) {
    local = local.translate(scrollX, scrollY);
    var node = findDataNode(local);
    var oh = _statusNode;
    _statusNode = null;
    if (node == null) {
      if (oh == null) {
        return;
      }
      oh.updateStatus(context, [NodeState.hover, NodeState.selected], null);
      sendHoverEndEvent(oh, local, global);
      repaint();
      onClickAfter(node, oh);
      return;
    }
    if (node != oh) {
      if (oh != null) {
        oh.updateStatus(context, [NodeState.hover, NodeState.selected], null);
        sendHoverEndEvent(oh, local, global);
      }
      node.updateStatus(context, null, [NodeState.hover, NodeState.selected]);
      sendClickEvent(node, local, global);
      _statusNode = node;
      onClickAfter(node, oh);
    }
  }

  void onClickAfter(DataNode? now, DataNode? old) {
    repaint();
  }

  void updateShowNodeSet() {
    showNodeSet.clear();
    showNodeSet.addAll(rBush.search(getVisibleArea()));
  }

  ///根据偏移量获取数据节点
  DataNode? findDataNode(Offset offset) {
    var result = rBush.search2(Rect.fromCircle(center: offset, radius: 4));
    for (var node in result) {
      if (node.contains(offset)) {
        return node;
      }
    }
    return null;
  }

  ///返回可见区域范围矩形
  Rect getVisibleArea() {
    return Rect.fromLTWH(-scrollX, -scrollY, width, height);
  }

  ///获取节点边界
  Rect getNodeBound(DataNode node) {
    return node.shape.bound;
  }

  ///保存数据集改变前的数据
  void saveOldNodeSet() {
    preNodeSet.clear();
    preNodeSet.addAll(nodeSet.nodeList);
  }

  ///设置一个新的数据
  void setNodeSet(Iterable<DataNode> nodeList) {
    nodeSet.clear();
    nodeSet.addAll(nodeList);
    rBush.clear();
    rBush.addAll(nodeList);
  }

  ///清除所有的数据集
  void clearNodeSet([bool saveToOld = false]) {
    if (saveToOld) {
      saveOldNodeSet();
    } else {
      preNodeSet.clear();
    }
    nodeSet.clear();
    showNodeSet.clear();
    rBush.clear();
  }

  ///获取视图中间点
  Offset centerPosition(List<SNumber> center) {
    return Offset(center.first.convert(width), center.last.convert(height));
  }

  ///标识是否在动画中
  bool inAnimation = false;

  ///获取动画相关配置
  AnimateOption? getAnimateOption(LayoutType type, [int objCount = -1]) {
    return null;
  }

  ///添加一个动画
  void addAnimate(List<AnimationNode> nodes) {
    context.addAnimateToQueue(nodes);
  }

  Coord? findCoord() {
    return geom.findCoord(context);
  }

  CoordView? findCoordView() {
    var view = context.viewManager.findCoord(geom.coordId);
    if (view != null) {
      if (view != parent) {
        throw IllegalStatusError("类型不匹配");
      }
    }

    return view;
  }
}

final class CombineShape {
  final CShape shape;
  final List<DataNode> nodeList;

  CombineShape(this.shape, this.nodeList);
}

///强制要求提供一个Geom和Layout
abstract class GeomView<T extends Geom> extends BaseGeomView<T> {
  GeomView(super.context, super.geom);

  @override
  void onUpdateDataCommand(covariant Command c) {
    onLayout(false, left, top, right, bottom);
  }

  @override
  void onGeomConfigChangeCommand(covariant Command c) {
    requestLayout();
  }

  ///布局节点位置
  ///在该方法内部实现了动画更新
  ///和新节点数据的获取和旧节点数据的保存
  @override
  FutureOr<void> onLayout(bool changed, double left, double top, double right, double bottom) async {
    saveOldNodeSet();
    List<DataNode> oldList = preNodeSet.nodeList;
    var pair = await _loadNewLayoutDataNodeSet();
    var newList = pair.first;
    var newLayoutList = pair.second;
    setNodeSet(newList);
    showNodeSet.setAll(newLayoutList);
    var transList = geom.transformList;
    var an = DiffUtil.diff(
      getAnimateOption(LayoutType.layout, oldList.length + newLayoutList.length),
      oldList,
      newLayoutList,
      (nodeList) {
        showNodeSet.setAll(nodeList);
        _handleDiffLayout(nodeList, transList);
      },
      onAnimateLerpStar,
      onAnimateLerpEnd,
      onAnimateLerpUpdate,
      onAnimateFrameUpdate,
      onStart: () {
        onAnimateStart(oldList, newLayoutList);
      },
      onEnd: () {
        onAnimateEnd(newLayoutList);
      },
    );
    addAnimate(an);
  }

  ///加载新的布局数据集
  FutureOr<Pair<List<DataNode>, List<DataNode>>> _loadNewLayoutDataNodeSet() async {
    List<DataNode> nodeList = [];
    var manager = context.dataManager;
    for (var data in geom.dataSet) {
      var node = manager.getNode(data.id);
      if (node == null) {
        Logger.w("获取转换节点失败，可能为内部状态失效");
      } else {
        nodeList.add(node);
      }
    }
    List<DataNode> newLayoutNodes = await clipNewLayoutNodes(nodeList);
    return Pair(nodeList, newLayoutNodes);
  }

  ///裁剪新的布局的节点数据量
  ///该方法可以由子类复写，返回特定范围的节点数据，减少布局计算量
  ///默认返回全部
  FutureOr<List<DataNode>> clipNewLayoutNodes(List<DataNode> newTotalDataSet) {
    return newTotalDataSet;
  }

  ///处理数据布局
  void _handleDiffLayout(List<DataNode> nodeList, List<ChartTransform> transList) {
    List<ChartTransform> interceptLayoutList = [];
    for (var transform in transList) {
      if (transform.onInterceptLayout(context, viewNotifier, nodeList, width, height)) {
        interceptLayoutList.add(transform);
      }
    }
    if (interceptLayoutList.isNotEmpty) {
      onLayoutNodeStart(nodeList, true);
      for (var transform in transList) {
        transform.onBuildNodeShape(nodeList);
      }
      onLayoutNodeEnd(nodeList, true);
    } else {
      onLayoutNodeStart(nodeList, false);
      for (var transform in transList) {
        transform.onBeforeLayout(context, viewNotifier, nodeList, width, height);
      }
      onLayoutPositionAndSize(nodeList);
      for (var transform in transList) {
        transform.onAfterLayout(context, nodeList, width, height);
      }
      onLayoutNodeEnd(nodeList, false);
    }
  }

  ///在布局节点之前回调
  void onLayoutNodeStart(List<DataNode> newList, bool isIntercept) {}

  void onLayoutPositionAndSize(List<DataNode> nodeList);

  void onLayoutNodeEnd(List<DataNode> nodeList, bool isIntercept) {}

  ///动画开始时回调
  void onAnimateStart(List<DataNode> oldList, List<DataNode> newList) {
    inAnimation = true;
    var tmp = [...oldList, ...newList];
    rBush.clear();
    rBush.addAll(tmp);
    updateShowNodeSet();
  }

  ///返回节点需要执行动画的开始值
  ///属性名必须和结束值相匹配
  Attrs onAnimateLerpStar(DataNode node, DiffType type) {
    return Attrs();
  }

  ///返回节点需要执行动画的结束值
  ///属性名必须和开始值相匹配
  Attrs onAnimateLerpEnd(DataNode node, DiffType type) {
    return Attrs();
  }

  ///更新节点动画属性
  void onAnimateLerpUpdate(DataNode node, Attrs s, Attrs e, double t, DiffType type) {}

  /// 当一次动画帧更新时所有节点都已更新后回调
  void onAnimateFrameUpdate(List<DataNode> list, double t) {
    showNodeSet.setAll(list);
    repaint();
  }

  ///动画结束时回调
  void onAnimateEnd(List<DataNode> newList) {
    inAnimation = false;
    rBush.clear();
    rBush.addAll(newList);
    updateShowNodeSet();
  }
}