import 'package:e_chart/e_chart.dart';

class TD3TreeTransform extends TreeTransform {
  ///分离函数，用于决定两个节点(一般为兄弟节点)之间的间距
  Fun3<TreeNode, TreeNode, num> splitFun = (a, b) {
    ///对于Radial布局 一般设置为 (a.parent == b.parent ? 1 : 2) / a.depth;
    return a.parent == b.parent ? 1 : 2;
  };

  /// 当该参数为true时，表示[onBeforeLayout]方法中的传入的参数为每层之间的间距
  /// 为false时则表示映射到给定的布局参数
  bool diff = false;

  TD3TreeTransform(
    super.parentFun,
    super.childFun, {
    this.diff = false,
    super.gapFun,
    super.levelGapFun,
    super.lineType,
    super.levelGapSize,
    super.nodeGapSize,
  });

  @override
  void transform2(Context context, double width, double height, TreeNode root) {
    num dx = width;
    num dy = height;
    InnerNode t = _treeRoot(root);
    t.eachAfter(_firstWalk);
    t.parent!.m = -t.z;
    t.eachBefore(_secondWalk);

    if (diff) {
      root.eachBefore((node, b, c) {
        _sizeNode(node, dx, dy);
        return false;
      });
    } else {
      var left = root, right = root, bottom = root;

      ///找到最右 最左 最低的节点
      root.eachBefore((node, b, c) {
        if (node.x < left.x) left = node;
        if (node.x > right.x) right = node;
        if (node.deep > bottom.deep) bottom = node;
        return false;
      });
      var split = left == right ? 1 : splitFun.call(left, right) / 2;
      var tx = split - left.x, kx = dx / (right.x + split + tx), ky = dy / (jsOr(bottom.deep, 1));
      root.eachBefore((node, b, c) {
        node.x = (node.x + tx) * kx;
        node.y = node.deep * ky;
        return false;
      });
    }
  }

  void _moveSubtree(InnerNode wm, InnerNode wp, num shift) {
    var change = shift / (wp.i - wm.i);
    wp.c -= change;
    wp.s += shift;
    wm.c += change;
    wp.z += shift;
    wp.m += shift;
  }

  void _executeShifts(InnerNode v) {
    num shift = 0.0;
    num change = 0;
    var children = v.children;
    int i = children.length;
    InnerNode w;
    while (--i >= 0) {
      w = children[i];
      w.z += shift;
      w.m += shift;
      shift += w.s + (change += w.c);
    }
  }

  InnerNode _nextAncestor(InnerNode vim, InnerNode v, InnerNode ancestor) {
    return vim.a!.parent == v.parent ? vim.a! : ancestor;
  }

  InnerNode _treeRoot(TreeNode root) {
    InnerNode tree = InnerNode(null, root, 0);
    List<InnerNode> nodes = [tree];
    List<TreeNode> children = [];
    while (nodes.isNotEmpty) {
      var node = nodes.removeLast();
      children = node.node!.children;
      if (children.isNotEmpty) {
        node.children.addAll(List.generate(children.length, (index) => InnerNode(null, null, 0)));
        for (int i = children.length - 1; i >= 0; --i) {
          var child = node.children[i] = InnerNode(null, children[i], i);
          nodes.add(child);
          child.parent = node;
        }
      }
    }
    var p = InnerNode(null, null, 0);
    tree.parent = p;
    p.children.add(tree);
    return tree;
  }

  bool _firstWalk(InnerNode v, b, c) {
    List<InnerNode> children = v.children;
    var siblings = v.parent!.children;
    InnerNode? w = jsTrue(v.i) ? siblings[v.i - 1] : null;
    if (children.isNotEmpty) {
      _executeShifts(v);
      var midpoint = (children[0].z + children[children.length - 1].z) / 2;
      if (w != null) {
        v.z = w.z + splitFun.call(v.node!, w.node!);
        v.m = v.z - midpoint;
      } else {
        v.z = midpoint;
      }
    } else if (w != null) {
      v.z = w.z + splitFun.call(v.node!, w.node!);
    }
    v.parent?.A = _apportion(v, w, jsOr(v.parent?.A, siblings[0]));
    return false;
  }

  bool _secondWalk(InnerNode v, b, c) {
    v.node!.x = v.z + v.parent!.m.toDouble();
    v.m += v.parent!.m;
    return false;
  }

  InnerNode _apportion(InnerNode v, InnerNode? w, InnerNode ancestor) {
    if (w != null) {
      InnerNode? vip = v;
      InnerNode vop = v;
      InnerNode? vim = w;
      InnerNode vom = vip.parent!.children[0];
      num sip = vip.m;
      num sop = vop.m;
      num sim = vim.m;
      num som = vom.m;
      num shift;
      while (true) {
        vim = _nextRight(vim!);
        vip = _nextLeft(vip!);
        if (!jsBoolAnd(vim, vip)) {
          break;
        }

        vom = _nextLeft(vom)!;
        vop = _nextRight(vop)!;
        vop.a = v;
        shift = vim!.z + sim - vip!.z - sip + splitFun.call(vim.node!, vip.node!);
        if (shift > 0) {
          _moveSubtree(_nextAncestor(vim, v, ancestor), v, shift);
          sip += shift;
          sop += shift;
        }
        sim += vim.m;
        sip += vip.m;
        som += vom.m;
        sop += vop.m;
      }
      if (jsTrue(vim) && !jsTrue(_nextRight(vop))) {
        vop.t = vim!;
        vop.m += sim - sop;
      }
      if (jsTrue(vip) && !jsTrue(_nextLeft(vom))) {
        vom.t = vip!;
        vom.m += sip - som;
        ancestor = v;
      }
    }
    return ancestor;
  }

  void _sizeNode(TreeNode node, num dx, num dy) {
    node.x *= dx;
    node.y = node.deep * dy.toDouble();
  }

  InnerNode? _nextLeft(InnerNode v) {
    var children = v.children;
    return children.isNotEmpty ? children[0] : v.t;
  }

  InnerNode? _nextRight(InnerNode v) {
    var children = v.children;
    return children.isNotEmpty ? children[children.length - 1] : v.t;
  }
}

class InnerNode {
  TreeNode? node;
  InnerNode? parent;
  List<InnerNode> children = [];
  int i;
  InnerNode? A; // default ancestor
  InnerNode? a; // ancestor

  num z = 0; // prelim
  num m = 0; // mod
  num c = 0; // change
  num s = 0; // shift
  InnerNode? t; // thread

  InnerNode(
    this.parent,
    this.node,
    this.i,
  ) {
    a = this;
  }

  ///先序遍历
  InnerNode eachBefore(InnerFun callback, [bool exitUseBreak = true]) {
    List<InnerNode> nodes = [this];
    List<InnerNode> children;
    int index = -1;
    while (nodes.isNotEmpty) {
      InnerNode node = nodes.removeLast();
      if (callback.call(node, ++index, this)) {
        if (exitUseBreak) {
          break;
        }
        continue;
      }
      children = node.children;
      nodes.addAll(children.reversed);
    }
    return this;
  }

  ///后序遍历
  InnerNode eachAfter(InnerFun callback, [bool exitUseBreak = true]) {
    List<InnerNode> nodes = [this];
    List<InnerNode> next = [];
    List<InnerNode> children;
    int index = -1;
    while (nodes.isNotEmpty) {
      InnerNode node = nodes.removeAt(nodes.length - 1);
      next.add(node);
      children = node.children;
      nodes.addAll(children);
    }
    while (next.isNotEmpty) {
      InnerNode node = next.removeAt(next.length - 1);
      if (callback.call(node, ++index, this)) {
        break;
      }
    }
    return this;
  }
}

typedef InnerFun = bool Function(InnerNode node, int index, InnerNode startNode);
