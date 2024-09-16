import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///具备层次结构的视图
///但该视图只能进行简单的动画
class TreeView extends GeomView<TreeGeom> {
  TreeNode? rootNode;

  Map<TreeNode, List<TreeNode>> _childMap = {};

  TreeView(super.context, super.series);

  @override
  void setNodeSet(Iterable<DataNode> nodeList) {
    recordChildMap();
    super.setNodeSet(nodeList);
    requestLayout();
  }

  void recordChildMap() {
    Map<TreeNode, List<TreeNode>> childMap = {};
    for (var node in nodeSet.nodeList) {
      var hn = node as TreeNode;
      childMap[hn] = List.from(hn.children);
    }
    _childMap = childMap;
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    var rootNode = geom.getTree(context);
    if (rootNode != null) {
      geom.transform.transform(context, width, height, rootNode);
      this.rootNode = rootNode;
    }
  }

  @override
  void onClickAfter(DataNode? now, DataNode? old) {
    if (now is! TreeNode) {
      return;
    }
    if (now.hasChild) {
      collapseNode(now);
    } else {
      expandNode(now);
    }
  }

  ///折叠一个节点
  void collapseNode(TreeNode data) {
    if (data.notChild) {
      return;
    }
    var rootNode = data.root;
    List<TreeNode> oldList = rootNode.iterator();
    var option = getAnimateOption(LayoutType.update, oldList.length);
    if (option == null) {
      data.clear();
      geom.transform.transform(context, width, height, rootNode);
      updateShowNodeSet();

      requestLayout();
      return;
    }

    final Set<TreeNode> childSet = {};
    each(data.children, (p0, p1) {
      childSet.addAll(p0.iterator());
    });
    Map<TreeNode, Offset> oldCenterMap = {};
    each(oldList, (p0, p1) {
      oldCenterMap[p0] = p0.center;
    });

    data.clear();
    geom.transform.transform(context, width, height, rootNode);
    Map<TreeNode, Offset> newCenterMap = {};
    rootNode.each((node, index, startNode) {
      newCenterMap[node] = node.center;
      return false;
    });
    var tween = Animate(0.0, 1.0, option: option);
    tween.addStartListener(() {
      //  dataSet = oldList;
    });

    tween.addListener((t) {
      each(oldList, (p0, p1) {
        if (childSet.contains(p0)) {
          p0.center = lerpOffset(oldCenterMap[p0]!, data.center, t);
        } else {
          p0.center = lerpOffset(oldCenterMap[p0]!, newCenterMap[p0]!, t);
        }
        var scale = childSet.contains(p0) ? 0 : 1;
        p0.shape.scale = lerpNum(1, scale, t);
      });
      repaint();
    });
    tween.addEndListener(() {
      updateShowNodeSet();
      repaint();
    });
    tween.start(context, true);
  }

  ///展开一个节点
  void expandNode(TreeNode clickNode) {
    var rootNode = clickNode.root;
    List<TreeNode>? children = _childMap[clickNode];
    if (children == null || children.isEmpty) {
      ///没有孩子无法展开
      return;
    }
    final cOffset = clickNode.center;
    final Set<TreeNode> childrenSet = {};
    each(children, (p0, p1) {
      childrenSet.addAll(p0.iterator());
    });

    Map<TreeNode, Offset> oldCenterMap = {};

    rootNode.each((node, index, startNode) {
      oldCenterMap[node] = node.center;
      return false;
    });

    var option = getAnimateOption(LayoutType.update, childrenSet.length + oldCenterMap.length);
    if (option == null) {
      clickNode.clear();
      clickNode.addAll(children);
      // _startLayout(_rootNode, false);
      // dataSet = _rootNode.iterator();
      // _rBush.clear();
      // _rBush.addAll(dataSet);
      repaint();
      return;
    }

    clickNode.clear();
    clickNode.addAll(children);
    //   _startLayout(rootNode, false);

    Map<TreeNode, Offset> newCenterMap = {};
    Map<TreeNode, Size> newSizeMap = {};
    rootNode.each((node, index, startNode) {
      newCenterMap[node] = node.center;
      newSizeMap[node] = node.size;
      return false;
    });
    var tween = Animate(0.0, 1.0, option: option);
    tween.addStartListener(() {
      //   dataSet = rootNode.iterator();
    });
    tween.addListener((t) {
      rootNode.each((node, index, startNode) {
        Offset offset = childrenSet.contains(node) ? cOffset : oldCenterMap[node]!;
        node.center = lerpOffset(offset, newCenterMap[node]!, t);
        double scale = childrenSet.contains(node) ? 0 : 1;
        node.shape.scale = lerpNum(scale, 1, t);
        return false;
      });
      repaint();
    });
    tween.addEndListener(() {
      //    updateNodeList(rootNode);
      repaint();
    });
    tween.start(context, true);
  }

  @override
  void onLayoutPositionAndSize(List<DataNode> nodeList) {}
}
