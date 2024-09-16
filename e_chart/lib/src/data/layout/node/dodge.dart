import 'package:e_chart/e_chart.dart';

///对数据分组
abstract class Dodge extends ChartTransform {
  Dim groupDim;
  Fun2<DataNode, String?>? stackIdFun;
  Fun3<DataNode, DataNode, int>? sortFun;
  List<SNumber>? groupRatios;
  SNumber padding;
  SNumber gap;

  Dodge({
    this.groupDim = Dim.x,
    this.sortFun,
    this.stackIdFun,
    this.padding = const SNumber(2, false),
    this.gap = const SNumber(2, false),
    this.groupRatios,
  });

  @override
  void onAfterLayout(Context context, List<DataNode> nodeList, double width, double height) {
    List<List<DataNode>> groupList = _group(nodeList);
    for (var item in groupList) {
      _adjust(item);
    }
  }

  void _adjust(List<DataNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    var sortFun = this.sortFun;
    if (sortFun != null) {
      nodeList.sort(sortFun);
    }

    var groupNode = GroupNode("ttt");
    List<ColumnNode> columnList = [];
    for (var node in nodeList) {
      var stackId = node.getStackId(stackIdFun);
      int index = columnList.indexWhere((element) => element.stackId == stackId);
      ColumnNode columnNode;
      if (index < 0) {
        columnNode = ColumnNode(groupNode, stackId);
      } else {
        columnNode = columnList[index];
      }
      columnNode.add(node);
    }

    final size = groupDim.isX ? nodeList.first.width : nodeList.first.height;
    var ratios =
        computeGroupSize(columnList.length, size, groupRatio: groupRatios, paddingRatio: padding, gapRatio: gap);
    each(columnList, (column, i) {
      var range = ratios[i];
      for (var node in column.dataList) {
        if (groupDim.isX) {
          node.width = range.second - range.first;
          node.x = (range.first + range.second) / 2;
        } else {
          node.height = range.second - range.first;
          node.y = (range.first + range.second) / 2;
        }
      }
    });
  }

  List<List<DataNode>> _group(Iterable<DataNode> nodeList) {
    Map<String, List<DataNode>> tmpMap = {};
    for (var node in nodeList) {
      var cat = node.getRawData(groupDim);
      if (cat == null) {
        Logger.w("data is null,current node group fail");
        continue;
      }
      var groupNode = tmpMap[cat] ?? [];
      tmpMap[cat] = groupNode;
      groupNode.add(node);
    }

    for (var entry in tmpMap.values) {
      var sortFun = this.sortFun;
      if (sortFun != null) {
        entry.sort(sortFun);
      } else {
        entry.sort((a, b) {
          return a.globalIndex.compareTo(b.globalIndex);
        });
      }
    }

    List<List<DataNode>> resultList = List.from(tmpMap.values);
    resultList.sort((a, b) {
      var a1 = groupDim.isX ? a.first.x : a.first.y;
      var b2 = groupDim.isX ? b.first.x : b.first.y;
      return a1.compareTo(b2);
    });
    return resultList;
  }
}
