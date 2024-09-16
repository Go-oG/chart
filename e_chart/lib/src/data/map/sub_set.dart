import 'package:e_chart/e_chart.dart';

///返回子集
class SubSetTransform extends DataTransform {
  int startIndex;
  int endIndex;
  Set<String> keepFields;

  SubSetTransform(
    this.startIndex, [
    this.endIndex = -1,
    this.keepFields = const <String>{},
  ]);

  @override
  List<RawData> transform(List<RawData> input) {
    if (endIndex <= 0 && keepFields.isEmpty) {
      return input;
    }
    var end = endIndex;
    if (end <= 0 || end > input.length - 1) {
      end = input.length - 1;
    }

    List<RawData> resultList =
        (startIndex == 0 && end == input.length - 1) ? input : input.sublist(startIndex, end + 1);
    if (keepFields.isEmpty) {
      return resultList;
    }

    Set<String> keys = Set.from(keepFields);
    resultList.each((p0, p1) {
      p0.removeNotInclude(keys);
    });
    return resultList;
  }
}
