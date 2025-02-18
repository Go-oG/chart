import 'package:e_chart/e_chart.dart';

///表示为系列数据
///该对象仅用于辅助布局
class GroupNode with AttrMixin {
  final String category;
  Map<String, ColumnNode> columns = {};

  GroupNode(this.category);

  void add(String stackId, DataNode data) {
    var cl = columns[stackId];
    if (cl == null) {
      cl = ColumnNode(this);
      columns[stackId] = cl;
    }
    cl.add(data);
  }

  ColumnNode first() {
    for (var entry in columns.entries) {
      return entry.value;
    }
    throw ChartError("违法调用");
  }

  int get columnCount => columns.length;

  List<ColumnNode> getSortColumn() {
    List<ColumnNode> list = List.from(columns.values);
    list.sort((a, b) {
      return a.dataList.first.globalIndex.compareTo(b.dataList.first.globalIndex);
    });
    return list;
  }

  bool get isEmpty => columns.isEmpty;
}
