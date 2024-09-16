import 'package:e_chart/src/utils/list_util.dart';

import '../types.dart';
import 'data.dart';

final class DataNodeSet {
  Map<String, DataNode> _nodeSet = {};
  List<DataNode> _nodeList = [];

  List<DataNode> get nodeList => _nodeList;

  DataNode? getNode(String id) {
    return _nodeSet[id];
  }

  ///上浮一个节点
  void upwardNode(DataNode node) {
    if (contains(node)) {
      var last = _nodeList.lastOrNull;
      if (last != node) {
        remove(node);
        _nodeSet[node.id] = node;
        _nodeList.add(node);
      }
    } else {
      _nodeSet[node.id] = node;
      _nodeList.add(node);
    }
  }

  void set(DataNode node) {
    clear();
    add(node);
  }

  void setAll(Iterable<DataNode> nodes) {
    clear();
    addAll(nodes);
  }

  void add(DataNode node) {
    var old = _nodeSet[node.id];
    if (old != null) {
      return;
    }
    _nodeSet[node.id] = node;
    _nodeList.add(node);
  }

  void addAll(Iterable<DataNode> nodes) {
    for (var node in nodes) {
      add(node);
    }
  }

  void remove(DataNode node) {
    if (_nodeSet.remove(node.id) != null) {
      _nodeList.remove(node);
    }
  }

  void removeAll(Iterable<DataNode> nodes) {
    for (var node in nodes) {
      remove(node);
    }
  }

  void removeWhere(Fun2<DataNode, bool> filter) {
    Set<DataNode> removeList = <DataNode>{};
    for (var node in _nodeSet.values) {
      if (filter.call(node)) {
        removeList.add(node);
      }
    }
    _nodeSet.removeWhere((s, t) => removeList.contains(t));
    _nodeList.removeAll(removeList);
  }

  void clear() {
    _nodeList = [];
    _nodeSet = {};
  }

  bool contains(DataNode node) {
    var old = _nodeSet[node.id];
    return old != null;
  }

  void dispose() {
    clear();
  }
}
