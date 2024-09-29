import 'package:e_chart/e_chart.dart';

///属性名字重新映射
class RenameTransform extends BaseDataTransform {
  late Map<String, String> fieldMap;

  RenameTransform([Map<String, String>? fieldMap]) {
    if (fieldMap == null) {
      this.fieldMap = {};
    } else {
      this.fieldMap = fieldMap;
    }
  }

  @override
  List<RawData> transform(List<RawData> input) {
    if (fieldMap.isEmpty) {
      return input;
    }
    for (var item in input) {
      for (var entry in fieldMap.entries) {
        var value = item.remove(entry.key);
        item.put(entry.value, value);
      }
    }
    return input;
  }
}
