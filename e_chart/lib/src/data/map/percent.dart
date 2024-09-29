import 'package:e_chart/e_chart.dart';

///百分比转换
class PercentTransform extends BaseDataTransform {
  ///该字段对应的值必须是num 或者为null
  String field;
  String dimension;
  List<String> groupBy;

  ///结果存储的字段值
  String asField;

  PercentTransform(this.field, this.dimension, this.groupBy, this.asField);

  @override
  List<RawData> transform(List<RawData> input) {
    ///先分组
    var gd = groupData(input, groupBy);
    Map<String, List<RawData>> groupMap = gd.first;

    ///对不同分组分别统计
    for (var entry in groupMap.entries) {
      Map<String, List<RawData>> dimMap = {};
      for (var item in entry.value) {
        var singleKey = key(item.get2(dimension));
        dimMap.get2(singleKey, []).add(item);
      }
      for (var list in dimMap.values) {
        num sumValue = sumBy(list, (p0) {
          var v = p0.get2(field);
          if (v == null) {
            return 0;
          }
          if (v is num) {
            return v;
          }
          throw TypeMatchError("field 字段对应的值必须是数值类型");
        });

        for (var item in list) {
          var v = item.get2(field);
          if (v == null) {
            item.put(asField, 0);
            continue;
          }
          item.put(asField, (sumValue == 0) ? 0 : v / sumValue);
        }
      }
    }

    return input;
  }
}
