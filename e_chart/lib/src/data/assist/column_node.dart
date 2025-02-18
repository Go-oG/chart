import 'package:e_chart/e_chart.dart';

class ColumnNode with AttrMixin {
  final GroupNode parent;

  late final String stackId;

  ColumnNode(this.parent, [String? stackId]) {
    this.stackId = isEmpty(stackId) ? randomId() : stackId!;
  }

  List<DataNode> dataList = [];

  void add(DataNode data) {
    dataList.add(data);
  }

  DataNode first() {
    return dataList.first;
  }
}
