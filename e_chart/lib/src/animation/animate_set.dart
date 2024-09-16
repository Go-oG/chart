import 'package:e_chart/e_chart.dart';

///用于实现多个动画的执行
class AnimateSet extends Animate<dynamic> {
  AnimateSet() : super(0, 0);

  List<Node> _playingNode = [];
  Map<Animate, Node> _mNodeMap = {};
  List<Node> _mNodes = [];

  Node? mCurrentNode;

  AnimateSet play(Animate anim) {
    var current = mCurrentNode;
    Node node = getNodeForAnimation(anim);
    if (current == null) {
      mCurrentNode = node;
      current = node;
    } else {
      current.addSibling(node);
    }
    return this;
  }

  AnimateSet playSequentially(List<Animate> items) {
    if (items.isEmpty) {
      return this;
    }
    for (var item in items) {
      Node node = getNodeForAnimation(item);
      var current = mCurrentNode;
      if (current != null) {
        current.addChild(node);
      }
      mCurrentNode = node;
    }
    return this;
  }

  AnimateSet playWith(Iterable<Animate> items) {
    for (var item in items) {
      Node node = getNodeForAnimation(item);
      var current = mCurrentNode;
      if (current == null) {
        mCurrentNode = node;
      } else {
        current.addSibling(node);
      }
    }
    return this;
  }

  AnimateSet before(Animate anim) {
    Node node = getNodeForAnimation(anim);
    var current = mCurrentNode;
    if (current != null) {
      current.addParent(node);
    }
    mCurrentNode = node;
    return this;
  }

  AnimateSet after(Animate anim) {
    Node node = getNodeForAnimation(anim);
    var current = mCurrentNode;
    if (current != null) {
      current.addChild(node);
    }
    mCurrentNode = node;
    return this;
  }

  Node getNodeForAnimation(Animate anim) {
    Node? node = _mNodeMap[anim];
    if (node == null) {
      node = Node(anim);
      _mNodeMap[anim] = node;
      _mNodes.add(node);
    }
    return node;
  }

  Node? _findRootNode() {
    var current = mCurrentNode;
    if (current == null) {
      return null;
    }
    Set<Node> nodeSet = <Node>{current};
    Set<Node> nextSet = <Node>{current};
    while (nodeSet.isNotEmpty) {
      for (var node in nodeSet) {
        nextSet.addAll(node._parents);
      }
      if (nextSet.isNotEmpty) {
        nodeSet = nextSet;
        nextSet = <Node>{};
      } else {
        return nodeSet.first;
      }
    }
    return null;
  }

  @override
  void start(Context context, [bool useUpdate = false]) {
    Node? rootNode = _findRootNode();
    if (rootNode == null) {
      return;
    }
    rootNode.start(context);
  }

  @override
  void stop([bool reset = true]) {
    for (var node in _playingNode) {
      node.stop();
    }
    _playingNode = [];
  }

  @override
  int get begin => throw UnimplementedError();

  @override
  int get end => throw UnimplementedError();

  @override
  void setTween(dynamic begin, dynamic end) {}
}

class Node {
  final Animate animate;

  final List<Node> _parents = [];
  final List<Node> _childList = [];
  final List<Node> _siblingList = [];

  ///该节点的关联节点
  Node? lastParent;

  bool running = false;

  Node(this.animate);

  void addChild(Node node) {
    if (!_childList.contains(node)) {
      _childList.add(node);
      node.addParent(this);
    }
  }

  void addSibling(Node node) {
    if (!_siblingList.contains(node)) {
      _siblingList.add(node);
      node.addSibling(this);
    }
  }

  void addParent(Node node) {
    if (!_parents.contains(node)) {
      _parents.add(node);
      node.addChild(this);
    }
  }

  void addParents(List<Node> parents) {
    if (parents.isEmpty) {
      return;
    }
    int size = parents.length;
    for (int i = 0; i < size; i++) {
      addParent(parents[i]);
    }
  }

  /// 从当前节点构建动画执行树
  void buildAnimateTree() {
    if (_childList.isEmpty && _siblingList.isEmpty) {
      return;
    }

    if (_siblingList.isNotEmpty) {
      animate.addEndListener(() {});
    }
    if (_childList.isNotEmpty) {
      animate.addStartListener(() {});
    }
  }

  void start(Context context) {
    if (_childList.isNotEmpty) {
      animate.addEndListener(() {
        for (var item in _childList) {
          item.start(context);
        }
      });
    }

    animate.start(context);
    for (var item in _siblingList) {
      item.start(context);
    }
  }

  void stop() {}
}
