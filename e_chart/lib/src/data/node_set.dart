import 'package:e_chart/src/utils/list_util.dart';

import '../model/error.dart';
import '../model/range_info.dart';
import '../types.dart';
import '../utils/math_util.dart';
import 'data_node.dart';

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

///用于优化解决大数据量下数据的获取
///支持按时间维度、字符串维度、数字维度来进行数据的管理
class DataStore<T> {
  static const int _storeSize = 500;

  dynamic Function(T data)? _accessor;

  dynamic Function(T data) get accessor => _accessor!;

  DataStore(this._accessor);

  Map<String, List<T>> _strMap = {};
  Map<int, List<T>> _timeMap = {};
  Map<int, List<T>> _numMap = {};

  ///存储数字基数
  late final double _numBase;

  void parse(List<T?> list) {
    _strMap = {};
    _timeMap = {};
    _numMap = {};
    List<T> numList = [];
    for (var node in list) {
      if (node == null) {
        continue;
      }
      dynamic key = accessor.call(node);
      if (key == null) {
        continue;
      }
      if (key is String) {
        List<T> strList = _strMap[key] ?? [];
        _strMap[key] = strList;
        strList.add(node);
        continue;
      }
      if (key is DateTime) {
        List<T> timeList = _timeMap[key.millisecondsSinceEpoch] ?? [];
        _timeMap[key.millisecondsSinceEpoch] = timeList;
        timeList.add(node);
        continue;
      }
      if (key is num) {
        numList.add(node);
        continue;
      }
      throw ChartError("只支持num、String、DateTime key type:${key.runtimeType}");
    }

    if (numList.isEmpty) {
      _numBase = 1;
      return;
    }

    if (numList.length == 1) {
      _numBase = 1;
    } else {
      var ext = extremes(numList, (p0) {
        return accessor.call(p0);
      });
      num diff = (ext.last - ext.first).abs();
      if (diff == 0) {
        diff = 1;
      }
      _numBase = diff / _storeSize;
    }
    for (var node in numList) {
      num key = accessor.call(node) as num;
      int page = (key / _numBase).floor();
      List<T> nl = _numMap[page] ?? [];
      _numMap[page] = nl;
      nl.add(node);
    }
  }

  List<List<T>> getByStr(List<String> list) {
    List<List<T>> sl = [];
    for (var str in list) {
      List<T>? tl = _strMap[str];
      if (tl != null) {
        sl.add(tl);
      }
    }
    return sl;
  }

  List<List<T>> getByTime(List<DateTime> list) {
    List<List<T>> rl = [];
    for (var time in list) {
      List<T>? tl = _timeMap[time.millisecondsSinceEpoch];
      if (tl != null) {
        rl.add(tl);
      }
    }
    return rl;
  }

  List<List<T>> getByNum(num start, num end) {
    if (start > end) {
      num t = start;
      start = end;
      end = t;
    }
    int si = (start / _numBase).floor();
    int ei = (end / _numBase).floor();
    List<List<T>> rl = [];
    for (int i = si; i <= ei; i++) {
      List<T>? tl = _numMap[i];
      if (tl != null) {
        rl.add(tl);
      }
      if (si == ei) {
        break;
      }
    }
    return rl;
  }

  List<T> getDataByRange(RangeInfo info) {
    List<T> resultList = [];
    if (info.numRange != null) {
      for (var list in getByNum(info.numRange!.first, info.numRange!.second)) {
        resultList.addAll(list);
      }
    }
    if (info.timeList != null) {
      for (var list in getByTime(info.timeList!)) {
        resultList.addAll(list);
      }
    }
    if (info.categoryList != null) {
      for (var list in getByStr(info.categoryList!)) {
        resultList.addAll(list);
      }
    }

    return resultList;
  }

  void dispose() {
    _accessor = null;
    _strMap = {};
    _timeMap = {};
    _numMap = {};
  }
}
