import 'dart:math';

import 'package:e_chart/e_chart.dart';

///将节点按照groupId分组
///对每个分组按照globalIndex 排序
List<List<DataNode>> groupByGroupId(Iterable<DataNode> nodeList, [VoidFun1<List<DataNode>>? sortFun]) {
  Map<String, List<DataNode>> map = {};
  for (var item in nodeList) {
    var groupId = item.groupId;
    var list = map[groupId] ?? [];
    map[groupId] = list;
    list.add(item);
  }
  for (var entry in map.entries) {
    var list = entry.value;
    if (list.length < 2) {
      continue;
    }
    if (sortFun != null) {
      sortFun.call(list);
    } else {
      sortGroupList(list);
    }
  }
  List<String> keys = List.from(map.keys);
  keys.sort((a, b) {
    return map[a]!.first.globalIndex.compareTo(map[b]!.first.globalIndex);
  });
  List<List<DataNode>> rl = [];
  for (var key in keys) {
    rl.add(map[key]!);
  }
  return rl;
}

void sortGroupList(List<DataNode> list) {
  list.sort((a, b) {
    return a.globalIndex.compareTo(b.globalIndex);
  });
}

///计算分组占用百分比
List<Pair<double, double>> computeGroupSize(
  int count,
  double size, {
  List<SNumber>? groupRatio,
  SNumber? gapRatio,
  SNumber? paddingRatio,
}) {
  checkArgs(count > 0);
  double allSize = 0;
  double padding = 0;
  double gap = 0;
  if (gapRatio != null) {
    gap = gapRatio.convert(size);
    allSize += gap * (count - 1);
  }
  if (paddingRatio != null) {
    padding = paddingRatio.convert(size);
    allSize += padding * 2;
  }

  double remainSize = size - allSize;
  if (remainSize > 0 && (groupRatio == null || groupRatio.isEmpty)) {
    double itemSize = remainSize / count;
    double off = padding;
    List<Pair<double, double>> resultList = [];
    for (var i = 0; i < count; i++) {
      resultList.add(Pair(off, off + itemSize));
      off += itemSize + gap;
    }
    return resultList;
  }
  allSize = padding * 2 + gap * (count - 1);
  List<double> dl = [];

  for (var i = 0; i < count; i++) {
    if (groupRatio == null || groupRatio.isEmpty) {
      dl.add(size / count);
    } else {
      if (i < groupRatio.length) {
        dl.add(groupRatio[i].convert(size));
      } else {
        dl.add(groupRatio.last.convert(size));
      }
    }
    allSize += dl[i];
  }

  var per = size / allSize;
  padding *= per;
  gap *= per;

  List<Pair<double, double>> resultList = [];
  double off = padding;
  for (var i = 0; i < count; i++) {
    var tmp = dl[i] * per;
    resultList.add(Pair(off, off + tmp));
    off += tmp + gap;
  }
  return resultList;
}

List<Pair<double, double>> computeGroupRatio(
  int count, {
  List<double>? groupRatio,
  double gap = 0,
  double padding = 0,
}) {
  checkArgs(count > 0);
  double allRatio = 0;
  allRatio += gap * (count - 1);
  allRatio += padding * 2;

  double remainRatio = 1 - allRatio;
  if (remainRatio > 0 && (groupRatio == null || groupRatio.isEmpty)) {
    double itemSize = remainRatio / count;
    double off = padding;
    List<Pair<double, double>> resultList = [];
    for (var i = 0; i < count; i++) {
      resultList.add(Pair(off, off + itemSize));
      off += itemSize + gap;
    }
    return resultList;
  }
  allRatio = padding * 2 + gap * (count - 1);
  List<double> dl = [];

  for (var i = 0; i < count; i++) {
    if (groupRatio == null || groupRatio.isEmpty) {
      dl.add(1 / count);
    } else {
      if (i < groupRatio.length) {
        dl.add(groupRatio[i]);
      } else {
        dl.add(groupRatio.last);
      }
    }
    allRatio += dl[i];
  }

  var per = 1 / allRatio;
  padding *= per;
  gap *= per;
  List<Pair<double, double>> resultList = [];
  double off = padding;
  for (var i = 0; i < count; i++) {
    var tmp = dl[i] * per;
    resultList.add(Pair(off, off + tmp));
    off += tmp + gap;
  }
  return resultList;
}

int findMaxColumnCount(List<GroupNode> list) {
  int c = 0;
  for (var node in list) {
    c = max(node.columnCount, c);
  }
  return c;
}
