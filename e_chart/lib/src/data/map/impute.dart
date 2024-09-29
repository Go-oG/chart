import 'package:e_chart/e_chart.dart';

///补全字段
class ImputeTransform extends BaseDataTransform {
  String field;
  ImputeMethod method;
  dynamic value;
  List<String> groupBy;

  ImputeTransform(
    this.field,
    this.groupBy, [
    this.method = ImputeMethod.max,
  ]);

  @override
  List<RawData> transform(List<RawData> input) {
    if (groupBy.isEmpty) {
      _fillGroup(input);
      return input;
    }
    var gd = groupData(input, groupBy);
    Map<String, List<RawData>> groupMap = gd.first;
    List<String> keyList = gd.second;

    List<RawData> resultList = [];
    for (var key in keyList) {
      var tmpList = groupMap[key]!;
      _fillGroup(tmpList);
      resultList.addAll(tmpList);
    }

    return resultList;
  }

  void _fillGroup(List<RawData> list) {
    dynamic fillData;
    if (method == ImputeMethod.value) {
      fillData = value;
    } else if (method == ImputeMethod.min || method == ImputeMethod.max) {
      List<RawData> extremeList = extremesBy(list, (a, b) {
        return compareValue(a.get2(field), b.get2(field));
      });
      if (extremeList.isNotEmpty) {
        if (method == ImputeMethod.min) {
          fillData = extremeList.first.get2(field);
        } else {
          fillData = extremeList.last.get2(field);
        }
      }
    } else if (method == ImputeMethod.median) {
      List<RawData> medianList = mediumBy2(list, (a, b) {
        return compareValue(a.get2(field), b.get2(field));
      });
      if (medianList.isNotEmpty) {
        if (medianList.length == 1) {
          fillData = medianList.first.get2(field);
        } else {
          fillData = medianValue(medianList.first.get2(field), medianList.last.get2(field));
        }
      }
    } else {
      fillData = aveBy(list, (p0) {
        var v = p0.get2(field);
        if (v == null) {
          return 0;
        }
        if (v is num) {
          return v;
        }
        if (v is DateTime) {
          return v.millisecondsSinceEpoch;
        }
        return 0;
      });
    }
    for (var item in list) {
      var tmpValue = item.get2(field);
      if (tmpValue == null) {
        item.put(field, fillData);
      }
    }
  }
}

enum ImputeMethod {
  max,
  min,
  median,
  mean,
  value;
}
