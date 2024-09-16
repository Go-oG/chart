import 'package:e_chart/e_chart.dart';

Pair<Map<String, List<RawData>>, List<String>> groupData(List<RawData> input, List<String> groupBy) {
  Map<String, List<RawData>> groupMap = {};
  List<String> keyList = [];
  for (var item in input) {
    var key = item.generateKey(groupBy);
    if (!groupMap.containsKey(key)) {
      groupMap[key] = [];
      keyList.add(key);
    }
    groupMap[key]!.add(item);
  }
  return Pair(groupMap, keyList);
}
