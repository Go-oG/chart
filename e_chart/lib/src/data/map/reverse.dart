import 'package:e_chart/e_chart.dart';

///翻转
class ReverseTransform extends DataTransform {
  @override
  List<RawData> transform(List<RawData> input) {
    if (input.isEmpty) {
      return input;
    }
    return List.from(input.reversed);
  }
}
