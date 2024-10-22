import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///当返回true 表示要终止遍历
typedef TreeEachFun = bool Function(TreeNode node, int index, TreeNode startNode);

class TreeNode extends DataNode with ExtProps {
  TreeNode? parent;
  List<TreeNode> _childrenList = [];

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
  int get parentIndex {
    if (parent == null) {
      return -1;
    }
    return parent!._childrenList.indexOf(this);
  }

  ///计算后代节点数
  ///后代节点数(包括子孙节点数)
  int _descendantCount = -1;

  int get descendantCount {
    if (_descendantCount < 0) {
      computeDescendantCount();
    }
    return _descendantCount;
  }

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
    _descendantCount = -1;
  }

  void addAll(Iterable<TreeNode> nodes) {
    for (var node in nodes) {
      add(node);
    }
  }

  void remove(TreeNode node, [bool resetParent = true]) {
    if (_childrenList.remove(node)) {
      _descendantCount = -1;
      if (resetParent) {
        node.parent = null;
      }
    }
  }

  TreeNode removeFirst([bool resetParent = true]) {
    return removeAt(0, resetParent: resetParent);
  }

  TreeNode removeLast([bool resetParent = true]) {
    return removeAt(_childrenList.length - 1, resetParent: resetParent);
  }

  TreeNode removeAt(
    int i, {
    bool resetParent = true,
  }) {
    var node = _childrenList.removeAt(i);
    if (resetParent) {
      node.parent = null;
    }
    _descendantCount = -1;
    return node;
  }

  void removeChild(bool Function(TreeNode) where, [bool resetParent = true]) {
    Set<TreeNode> removeSet = <TreeNode>{};
    _childrenList.removeWhere((e) {
      if (where.call(e)) {
        removeSet.add(e);
        return true;
      }
      return false;
    });
    if (resetParent) {
      for (var item in removeSet) {
        item.parent = null;
      }
    }
  }

  void removeWhere(bool Function(TreeNode) where, {bool iterator = false, bool resetParent = true}) {
    List<TreeNode> nodeList = [this];
    while (nodeList.isNotEmpty) {
      TreeNode first = nodeList.removeAt(0);
      first.removeChild(where, resetParent);
      if (iterator) {
        nodeList.addAll(first.children);
      }
    }
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
  List<List<TreeNode>> levelEach([int maxLevel = -1]) {
    List<List<TreeNode>> resultList = [];
    List<TreeNode> list = [this];
    List<TreeNode> next = [];
    if (maxLevel <= 0) {
      maxLevel = 2 ^ 16;
    }
    while (list.isNotEmpty && maxLevel > 0) {
      resultList.add(list);
      for (var c in list) {
        next.addAll(c.children);
      }
      list = next;
      next = [];
      maxLevel--;
    }
    return resultList;
  }

  void bfsEach(void Function(TreeNode, int) f, [int maxLevel = -1]) {
    if (maxLevel <= 0) {
      maxLevel = 2 ^ 53;
    }
    List<Pair<TreeNode, int>> queue = [Pair(this, 0)];
    while (queue.isNotEmpty) {
      var tmp = queue.removeAt(0);
      var node = tmp.first;
      int depth = tmp.second;
      f.call(node, depth);
      if (depth < maxLevel) {
        for (var child in node.children) {
          queue.add(Pair(child, depth + 1));
        }
      }
    }
  }

  TreeNode each(TreeEachFun callback) {
    int index = -1;
    for (var node in iterator()) {
      if (callback.call(node, ++index, this)) {
        break;
      }
    }
    return this;
  }

  ///先序遍历
  TreeNode eachBefore(TreeEachFun callback) {
    List<TreeNode> nodes = [this];
    List<TreeNode> children;
    int index = -1;
    while (nodes.isNotEmpty) {
      TreeNode node = nodes.removeLast();
      if (callback.call(node, ++index, this)) {
        break;
      }
      children = node._childrenList;
      nodes.addAll(children.reversed);
    }
    return this;
  }

  ///后序遍历
  TreeNode eachAfter(TreeEachFun callback) {
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
  TreeNode? findInChildren(TreeEachFun where) {
    return findWhere(where, iterator: false, limit: 1).firstOrNull;
  }

  TreeNode? find(TreeEachFun where) {
    return findWhere(where, iterator: true).firstOrNull;
  }

  List<TreeNode> findWhere(
    TreeEachFun where, {
    bool iterator = true,
    int limit = -1,
  }) {
    if (limit <= 0) {
      limit = 2 << 53;
    }

    List<TreeNode> list = [];
    if (!iterator) {
      int index = 0;
      for (var item in _childrenList) {
        if (where.call(item, index, this)) {
          list.add(item);
        }
        if (list.length >= limit) {
          break;
        }
        index++;
      }
      return list;
    }

    each((node, index, startNode) {
      if (where.call(node, index, this)) {
        list.add(node);
      }
      if (list.length >= limit) {
        return true;
      }
      return false;
    });
    return list;
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
  List<TreeNode> findPath(TreeNode target) {
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

  TreeNode sort(Fun3<TreeNode, TreeNode, int> sortFun, [bool iterator = true]) {
    if (iterator) {
      eachBefore((TreeNode node, b, c) {
        if (node.childCount > 1) {
          node._childrenList.sort(sortFun);
        }
        return false;
      });
      return this;
    }
    _childrenList.sort(sortFun);
    return this;
  }

  ///统计并计算一些信息
  ///计算节点value、深度、高度
  void compute({
    Fun3<TreeNode, TreeNode, int>? sortFun,
    bool sortIterator = true,
    bool computeDepth = true,
    int currentDepth = 0,
    int initHeight = 0,
    bool computeSum = true,
    bool sumUseParent = true,
    bool throwError = true,
  }) {
    if (sortFun != null) {
      sort(sortFun, sortIterator);
    }
    if (computeDepth) {
      setDeep(currentDepth, true);
      computeHeight(initHeight);
      setMaxDeep(treeHeight);
    }
    if (computeSum) {
      this.computeSum(throwError: throwError, useParent: sumUseParent);
    }
  }

  ///计算当前节点的后代数
  int computeDescendantCount() {
    eachAfter((TreeNode node, b, c) {
      int sum = 0;
      List<TreeNode> children = node._childrenList;
      int i = children.length;
      if (i == 0) {
        sum = 1;
      } else {
        while (--i >= 0) {
          sum += children[i]._descendantCount;
        }
      }
      node._descendantCount = sum;
      return false;
    });
    return _descendantCount;
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

  void computeSum({bool throwError = true, bool useParent = true}) {
    levelEach().eachRight((list, p1) {
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

  void setTreeHeight(int height, [bool iterator = true]) {
    treeHeight = height;
    if (iterator) {
      for (var node in _childrenList) {
        node.setTreeHeight(height - 1, true);
      }
    }
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
    node._descendantCount = _descendantCount;
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
