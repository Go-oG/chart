import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

typedef TreeFun = bool Function(TreeNode node, int index, TreeNode startNode);

class TreeNode extends DataNode with ExtProps {
  TreeNode? parent;
  List<TreeNode> _childrenList = [];

  ///后代节点数
  int _count = 0;
  bool _expand = true; //是否展开
  double get areaRatio {
    if (parent == null) {
      return 1;
    }
    return value / parent!.value;
  }

  TreeNode(
    super.series,
    super.data,
    this.parent,
    List<TreeNode> children, {
    super.value = 0,
    super.deep = 0,
    super.priority,
    super.index,
  }) {
    _childrenList.addAll(children);
  }

  void removeChild(bool Function(TreeNode) filter) {
    _childrenList.removeWhere(filter);
  }

  TreeNode removeAt(int i) {
    return _childrenList.removeAt(i);
  }

  TreeNode removeFirst() {
    return removeAt(0);
  }

  TreeNode removeLast() {
    return removeAt(_childrenList.length - 1);
  }

  void removeWhere(bool Function(TreeNode) where, [bool iterator = false]) {
    if (!iterator) {
      _childrenList.removeWhere(where);
      return;
    }

    List<TreeNode> nodeList = [this];
    while (nodeList.isNotEmpty) {
      TreeNode first = nodeList.removeAt(0);
      first._childrenList.removeWhere(where);
      nodeList.addAll(first._childrenList);
    }
  }

  List<TreeNode> get children {
    return _childrenList;
  }

  List<TreeNode> get childrenReverse => List.from(_childrenList.reversed);

  bool get hasChild {
    return _childrenList.isNotEmpty;
  }

  bool get notChild {
    return _childrenList.isEmpty;
  }

  int get childCount => _childrenList.length;

  /// 自身在父节点中的索引 如果为-1表示没有父节点
  int get childIndex {
    if (parent == null) {
      return -1;
    }
    return parent!._childrenList.indexOf(this);
  }

  ///返回后代节点数
  ///调用该方法前必须先调用 computeCount，否则永远返回0
  int get count => _count;

  TreeNode get root {
    TreeNode? tmpRoot = this;
    while (tmpRoot != null) {
      if (tmpRoot.parent == null) {
        return tmpRoot;
      }
      tmpRoot = tmpRoot.parent;
    }

    throw ChartError("状态异常");
  }

  TreeNode childAt(int index) {
    return _childrenList[index];
  }

  TreeNode get firstChild {
    return childAt(0);
  }

  TreeNode get lastChild {
    return childAt(_childrenList.length - 1);
  }

  void add(TreeNode node) {
    if (node.parent != null && node.parent != this) {
      throw ChartError('当前要添加的节点其父节点不为空');
    }
    node.parent = this;
    if (_childrenList.contains(node)) {
      return;
    }
    _childrenList.add(node);
  }

  void addAll(Iterable<TreeNode> nodes) {
    for (var node in nodes) {
      add(node);
    }
  }

  void remove(TreeNode node) {
    _childrenList.remove(node);
  }

  void clear() {
    var cs = _childrenList;
    _childrenList = [];
    for (var c in cs) {
      c.parent = null;
    }
  }

  /// 返回其所有的叶子结点
  List<TreeNode> leaves() {
    List<TreeNode> resultList = [];
    eachBefore((TreeNode a, int b, TreeNode c) {
      if (a.notChild) {
        resultList.add(a);
      }
      return false;
    });
    return resultList;
  }

  /// 返回其所有后代节点
  List<TreeNode> descendants() {
    return iterator();
  }

  ///返回其后代所有节点(按照拓扑结构)
  List<TreeNode> iterator() {
    List<TreeNode> resultList = [];
    TreeNode? node = this;
    List<TreeNode> current = [];
    List<TreeNode> next = [node];
    List<TreeNode> children = [];
    do {
      current = List.from(next.reversed);
      next = [];
      while (current.isNotEmpty) {
        node = current.removeLast();
        resultList.add(node);
        children = node.children;
        if (children.isNotEmpty) {
          for (int i = 0, n = children.length; i < n; ++i) {
            next.add(children[i]);
          }
        }
      }
    } while (next.isNotEmpty);

    return resultList;
  }

  /// 返回从当前节点开始的祖先节点
  List<TreeNode> ancestors() {
    List<TreeNode> resultList = [this];
    TreeNode? node = this;
    while ((node = node?.parent) != null) {
      resultList.add(node!);
    }
    return resultList;
  }

  ///层序遍历
  List<List<TreeNode>> levelEach([int level = -1]) {
    List<List<TreeNode>> resultList = [];
    List<TreeNode> list = [this];
    List<TreeNode> next = [];
    if (level <= 0) {
      level = 2 ^ 16;
    }
    while (list.isNotEmpty && level > 0) {
      resultList.add(list);
      for (var c in list) {
        next.addAll(c.children);
      }
      list = next;
      next = [];
      level--;
    }
    return resultList;
  }

  TreeNode each(TreeFun callback, [bool exitUseBreak = true]) {
    int index = -1;
    for (var node in iterator()) {
      if (callback.call(node, ++index, this)) {
        break;
      }
    }
    return this;
  }

  ///先序遍历
  TreeNode eachBefore(TreeFun callback, [bool exitUseBreak = true]) {
    List<TreeNode> nodes = [this];
    List<TreeNode> children;
    int index = -1;
    while (nodes.isNotEmpty) {
      TreeNode node = nodes.removeLast();
      if (callback.call(node, ++index, this)) {
        if (exitUseBreak) {
          break;
        }
        continue;
      }
      children = node._childrenList;
      nodes.addAll(children.reversed);
    }
    return this;
  }

  ///后序遍历
  TreeNode eachAfter(TreeFun callback, [bool exitUseBreak = true]) {
    List<TreeNode> nodes = [this];
    List<TreeNode> next = [];
    List<TreeNode> children;
    int index = -1;
    while (nodes.isNotEmpty) {
      TreeNode node = nodes.removeAt(nodes.length - 1);
      next.add(node);
      children = node._childrenList;
      nodes.addAll(children);
    }
    while (next.isNotEmpty) {
      TreeNode node = next.removeAt(next.length - 1);
      if (callback.call(node, ++index, this)) {
        break;
      }
    }
    return this;
  }

  ///在子节点中查找对应节点
  TreeNode? findInChildren(TreeFun callback) {
    int index = -1;
    for (TreeNode node in _childrenList) {
      if (callback.call(node, ++index, this)) {
        return node;
      }
    }
    return null;
  }

  TreeNode? find(TreeFun callback) {
    TreeNode? result;
    each((node, index, startNode) {
      if (callback.call(node, index, this)) {
        result = node;
        return true;
      }
      return false;
    });
    return result;
  }

  /// 从当前节点开始查找深度等于给定深度的节点
  /// 广度优先遍历 [only]==true 只返回对应层次的,否则返回<=
  List<TreeNode> depthNode(int depth, [bool only = true]) {
    if (deep > depth) {
      return [];
    }
    List<TreeNode> resultList = [];
    List<TreeNode> tmp = [this];
    List<TreeNode> next = [];
    while (tmp.isNotEmpty) {
      for (var node in tmp) {
        if (only) {
          if (node.deep == depth) {
            resultList.add(node);
          } else {
            next.addAll(node._childrenList);
          }
        } else {
          resultList.add(node);
          next.addAll(node._childrenList);
        }
      }
      tmp = next;
      next = [];
    }
    return resultList;
  }

  ///返回当前节点的后续的所有Link
  List<Link<TreeNode>> links() {
    List<Link<TreeNode>> links = [];
    each((node, index, startNode) {
      if (node != this && node.parent != null) {
        links.add(Link(node.parent!, node));
      }
      return false;
    });
    return links;
  }

  ///返回从当前节点到指定节点的最短路径
  List<TreeNode> targetPath(TreeNode target) {
    TreeNode? start = this;
    TreeNode? end = target;
    TreeNode? ancestor = minCommonAncestor(start, end);
    List<TreeNode> nodes = [start];
    while (ancestor != start) {
      start = start?.parent;
      if (start != null) {
        nodes.add(start);
      }
    }
    var k = nodes.length;
    while (end != ancestor) {
      nodes.insert(k, end!);
      end = end.parent;
    }
    return nodes;
  }

  TreeNode sort(int Function(TreeNode, TreeNode) compare, [bool iterator = true]) {
    if (iterator) {
      return eachBefore((TreeNode node, b, c) {
        if (node.childCount > 1) {
          node._childrenList.sort(compare);
        }
        return false;
      });
    }
    _childrenList.sort(compare);
    return this;
  }

  ///计算当前节点值
  ///如果给定了回调,那么将使用给定的回调进行值统计
  ///否则直接使用 _value 统计
  TreeNode sum([num Function(TreeNode)? valueCallback, bool throwError = true]) {
    return eachAfter((TreeNode node, b, c) {
      num sum = valueCallback == null ? node.value : valueCallback(node);
      if (sum.isNaN || sum.isInfinite) {
        if (throwError) {
          throw ChartError("Sum is NaN or Infinite");
        }
        sum = 0;
      }
      List<TreeNode> children = node._childrenList;
      int i = children.length;
      while (--i >= 0) {
        sum += children[i].value;
      }
      node.value = sum.toDouble();
      return false;
    });
  }

  ///返回当前节点下最左边的叶子节点
  TreeNode leafLeft() {
    List<TreeNode> children = [];
    TreeNode node = this;
    while ((children = node.children).isNotEmpty) {
      node = children[0];
    }
    return node;
  }

  TreeNode leafRight() {
    List<TreeNode> children = [];
    TreeNode node = this;
    while ((children = node.children).isNotEmpty) {
      node = children[children.length - 1];
    }
    return node;
  }

  /// 计算当前节点的后代节点数
  int computeCount() {
    eachAfter((TreeNode node, b, c) {
      int sum = 0;
      List<TreeNode> children = node._childrenList;
      int i = children.length;
      if (i == 0) {
        sum = 1;
      } else {
        while (--i >= 0) {
          sum += children[i]._count;
        }
      }
      node._count = sum;
      return false;
    });
    return _count;
  }

  /// 计算树的高度
  void computeHeight([int initHeight = 0]) {
    List<List<TreeNode>> levelList = [];
    List<TreeNode> tmp = [this];
    List<TreeNode> next = [];
    while (tmp.isNotEmpty) {
      levelList.add(tmp);
      next = [];
      for (var c in tmp) {
        next.addAll(c.children);
      }
      tmp = next;
    }
    int c = levelList.length;
    for (int i = 0; i < c; i++) {
      for (var node in levelList[i]) {
        node.treeHeight = c - i - 1;
      }
    }
  }

  ///设置深度
  void setDeep(int deep, [bool iterator = true]) {
    this.deep = deep;
    if (iterator) {
      for (var node in _childrenList) {
        node.setDeep(deep + 1, true);
      }
    }
  }

  void setMaxDeep(int maxDeep, [bool iterator = true]) {
    this.maxDeep = maxDeep;
    if (iterator) {
      for (var node in _childrenList) {
        node.setMaxDeep(maxDeep, iterator);
      }
    }
  }

  //设置树高度
  void setTreeHeight(int height, [bool iterator = true]) {
    treeHeight = height;
    if (iterator) {
      for (var node in _childrenList) {
        node.setTreeHeight(height - 1, true);
      }
    }
  }

  int findMaxDeep() {
    int i = 0;
    leaves().forEach((element) {
      i = max(i, element.deep);
    });
    return i;
  }

  //=======坐标相关的操作========

  ///找到一个节点是否在[offset]范围内
  TreeNode? findNodeByOffset(Offset offset, [bool useRadius = true, bool shordSide = true]) {
    double r = (shordSide ? size.shortestSide : size.longestSide) / 2;
    r *= r;
    return find((node, index, startNode) {
      if (useRadius) {
        double a = (offset.dx - node.x).abs();
        double b = (offset.dy - node.y).abs();
        return (a * a + b * b) <= r;
      } else {
        return node.position.contains(offset);
      }
    });
  }

  void translate(num dx, num dy) {
    each((node, index, startNode) {
      node.x += dx;
      node.y += dy;
      return false;
    });
  }

  void right2Left() {
    Rect bound = getBoundBox();
    each((node, index, startNode) {
      node.x = node.x - (node.x - bound.left) * 2;
      return false;
    });
  }

  void bottom2Top() {
    Rect bound = getBoundBox();
    each((node, index, startNode) {
      node.y = node.y - (node.y - bound.top) * 2;
      return false;
    });
  }

  ///获取包围整个树的范围
  Rect getBoundBox() {
    num left = x;
    num right = x;
    num top = y;
    num bottom = y;
    each((node, index, startNode) {
      left = min(left, node.x);
      top = min(top, node.y);
      right = max(right, node.x);
      bottom = max(bottom, node.y);
      return false;
    });
    return Rect.fromLTRB(left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
  }

  Rect get position => Rect.fromCenter(center: center, width: size.width, height: size.height);

  set position(Rect rect) {
    Offset center = rect.center;
    x = center.dx;
    y = center.dy;
    size = rect.size;
  }

  ///从复制当前节点及其后代
  ///复制后的节点没有parent
  TreeNode copy(TreeNode Function(TreeNode?, TreeNode) build, [int deep = 0]) {
    return _innerCopy(build, null, deep);
  }

  TreeNode _innerCopy(TreeNode Function(TreeNode?, TreeNode) build, TreeNode? parent, int deep) {
    TreeNode node = build.call(parent, this);
    node.parent = parent;
    node.deep = deep;
    node.value = value;
    node.treeHeight = treeHeight;
    node._count = _count;
    node._expand = _expand;
    for (var ele in _childrenList) {
      node.add(ele._innerCopy(build, node, deep + 1));
    }
    return node;
  }

  set expand(bool b) {
    _expand = b;
    for (var element in _childrenList) {
      element.expand = b;
    }
  }

  void setExpand(bool e, [bool iterator = true]) {
    _expand = e;
    if (iterator) {
      for (var element in _childrenList) {
        element.setExpand(e, iterator);
      }
    }
  }

  bool get expand => _expand;

  bool get isLeaf => childCount <= 0;

  @override
  String toString() {
    return "$runtimeType:\ndeep:$deep height:$treeHeight maxDeep:$maxDeep\nchildCount:$childCount\n";
  }

  ///返回 节点 a,b的最小公共祖先
  static TreeNode? minCommonAncestor(TreeNode a, TreeNode b) {
    if (a == b) return a;
    var aNodes = a.ancestors();
    var bNodes = b.ancestors();
    TreeNode? c;
    a = aNodes.removeLast();
    b = bNodes.removeLast();
    while (a == b) {
      c = a;
      a = aNodes.removeLast();
      b = bNodes.removeLast();
    }
    return c;
  }
}

TreeNode? toTree(Context context, Geom series, List<RawData?> list, Fun2<String, String?> parentFun,
    Fun2<String, List<String>?> childFun) {
  var manager = context.dataManager;
  each(list, (data, p1) {
    if (data == null) {
      return;
    }
    var node = manager.getNode(data.id);
    if (node == null) {
      Logger.w("id:${data.id} not find Node");
      return;
    }
    if (node is! TreeNode) {
      throw ChartError("Node must TreeNode child Class");
    }

    node.parent = null;
    node.clear();
  });

  each(list, (p0, p1) {
    if (p0 == null) {
      return;
    }
    var selfNode = manager.getNode(p0.id);
    if (selfNode == null || selfNode is! TreeNode) {
      return;
    }
    childFun.call(p0.id)?.each((child, index) {
      var childNode = manager.getNode(child);
      if (childNode == null || childNode is! TreeNode) {
        return;
      }
      selfNode.add(childNode);
    });
  });

  for (var entry in list) {
    if (entry == null) {
      continue;
    }
    var node = manager.getNode(entry.id);
    if (node == null || node is! TreeNode) {
      continue;
    }
    return node.root;
  }
  return null;
}

TreeNode? toTree2(
    Context context, List<DataNode?> list, Fun2<String, String?> parentFun, Fun2<String, List<String>?> childFun) {
  var manager = context.dataManager;
  each(list, (data, p1) {
    if (data == null) {
      return;
    }
    var node = manager.getNode(data.id);
    if (node == null) {
      Logger.w("id:${data.id} not find Node");
      return;
    }
    if (node is! TreeNode) {
      throw ChartError("Node must TreeNode child Class");
    }

    node.parent = null;
    node.clear();
  });

  each(list, (p0, p1) {
    if (p0 == null) {
      return;
    }
    var selfNode = manager.getNode(p0.id);
    if (selfNode == null || selfNode is! TreeNode) {
      return;
    }
    childFun.call(p0.id)?.each((child, index) {
      var childNode = manager.getNode(child);
      if (childNode == null || childNode is! TreeNode) {
        return;
      }
      selfNode.add(childNode);
    });
  });

  for (var entry in list) {
    if (entry == null) {
      continue;
    }
    var node = manager.getNode(entry.id);
    if (node == null || node is! TreeNode) {
      continue;
    }
    return node.root;
  }
  return null;
}

///统计并计算一些信息
///计算节点value、深度、高度
void computeTree(TreeNode root,
    {Fun3<TreeNode, TreeNode, int>? sortFun, bool throwError = true, bool useParent = true}) {
  var sort = sortFun;
  if (sort != null) {
    root.sort(sort, true);
  }
  treeSumOpt(root, throwError: throwError, useParent: useParent);
  root.setDeep(0);
  root.computeHeight();
  root.setMaxDeep(root.treeHeight);
}

///优化后的统计求和数据
void treeSumOpt(TreeNode root, {bool throwError = true, bool useParent = true}) {
  root.levelEach().eachRight((list, p1) {
    for (var node in list) {
      if (node.hasChild) {
        double sum = 0;
        for (var child in node.children) {
          sum += child.value;
        }
        var value = node.value;
        if (value.isNaN || value.isInfinite || value <= sum) {
          node.value = sum;
        } else {
          node.value = useParent ? node.value : sum;
        }
      } else {
        if (node.value.isInfinite || node.value.isNaN) {
          if (throwError) {
            throw ChartError("违法数据 ${node.data}");
          }
          node.value = 0;
        }
      }
    }
  });
}
