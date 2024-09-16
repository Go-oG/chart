import 'package:e_chart/e_chart.dart';

class RangeInfo {
  final List<String>? categoryList;
  final List<DateTime>? timeList;
  final Pair<num, num>? numRange;

  const RangeInfo.category(List<String> list)
      : categoryList = list,
        timeList = null,
        numRange = null;

  const RangeInfo.time(List<DateTime> list)
      : timeList = list,
        categoryList = null,
        numRange = null;

  const RangeInfo.range(Pair<num, num> pair)
      : timeList = null,
        categoryList = null,
        numRange = pair;

  @override
  String toString() {
    if (categoryList != null) {
      return "C:$categoryList";
    }
    if (timeList != null) {
      return "T:$timeList";
    }
    if (numRange != null) {
      return "N:[${numRange!.first} , ${numRange!.second}]";
    }

    return "暂无数据";
  }

  bool includeData(dynamic data) {
    if (data is String) {
      return categoryList?.contains(data) ?? false;
    }
    if (data is num) {
      if (numRange == null) {
        return false;
      }
      return numRange!.first <= data && data <= numRange!.second;
    }
    if (data is DateTime) {
      if (timeList == null || timeList!.isEmpty) {
        return false;
      }

      return timeList!.first.millisecondsSinceEpoch <= data.millisecondsSinceEpoch &&
          timeList!.last.millisecondsSinceEpoch >= data.millisecondsSinceEpoch;
    }
    throw ChartError("不支持的数据");
  }
}
