import 'package:e_chart/e_chart.dart';

///数据展开
class FoldTransform extends DataTransform {
  ///需要展开的字段
  List<String> fields;

  ///展开字段映射名字
  String key;
  String value;

  ///需要保留的字段集
  ///如果为空则保留除fields以外的全部字段
  List<String> retains;

  FoldTransform(this.fields, this.key, this.value, [this.retains = const []]);

  @override
  List<RawData> transform(List<RawData> input) {
    List<RawData> rowList = [];
    for (var item in input) {
      List<Map<String, dynamic>> mapList = [];
      for (var entry in item.pick(fields).entries) {
        Map<String, dynamic> tmpMap = {};
        mapList.add(tmpMap);
        tmpMap[key] = entry.key;
        tmpMap[value] = entry.value;
      }

      if (retains.isEmpty) {
        item.removeAt(fields);
        for (var map in mapList) {
          map.addAll(item.getAll());
          rowList.add(RawData.fromMap(map));
        }
      } else {
        var copy = item.pick(retains);
        for (var key in fields) {
          copy.remove(key);
        }
        for (var map in mapList) {
          map.addAll(copy);
          rowList.add(RawData.fromMap(map));
        }
      }
    }
    return rowList;
  }
}
