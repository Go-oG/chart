import 'package:e_chart/e_chart.dart';

///过滤
class FilterTransform extends DataTransform {
  Fun2<RawData, bool> filterFun;

  FilterTransform(this.filterFun);

  @override
  List<RawData> transform(List<RawData> input) {
    input.removeWhere(filterFun);
    return input;
  }
}
