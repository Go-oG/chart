import 'package:e_chart/e_chart.dart';

///对数据分组排序(类似SQL的groupBy orderBy)
class GroupTransform extends DataTransform {
  List<String> groupBy;
  List<String> orderBy;

  GroupTransform({
    this.groupBy = const [],
    this.orderBy = const [],
  });

  @override
  List<RawData> transform(List<RawData> input) {
    if (groupBy.isEmpty) {
      return SortByTransform(orderBy).transform(input);
    }
    var gd = groupData(input, groupBy);
    Map<String, List<RawData>> groupMap = gd.first;
    List<String> keyList = gd.second;

    var sortTransform = SortByTransform(orderBy);
    List<RawData> resultList = [];
    for (var key in keyList) {
      var tmpList = groupMap[key]!;
      tmpList = sortTransform.transform(tmpList);
      resultList.addAll(tmpList);
    }
    return resultList;
  }
}
