import 'package:e_chart/e_chart.dart';

///只保留指定字段的数据
class PickTransform extends DataTransform {
  late Set<String> fields;

  PickTransform([Iterable<String>? fields]) {
    if (fields == null) {
      this.fields = <String>{};
    } else {
      this.fields = Set.from(fields);
    }
  }

  @override
  List<RawData> transform(List<RawData> input) {
    if (fields.isEmpty) {
      return input;
    }
    input.each((data, p1) {
      data.removeNotInclude(fields);
    });
    return input;
  }
}
