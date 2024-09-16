import 'package:e_chart/e_chart.dart';

///排序
class SortTransform extends DataTransform {
  int takeTopCount;
  Fun3<RawData, RawData, int> sortFun;

  SortTransform(this.sortFun, {this.takeTopCount = -1});

  @override
  List<RawData> transform(List<RawData> input) {
    input.sort(sortFun);
    if (takeTopCount <= 0 || takeTopCount >= input.length) {
      return input;
    }
    return input.sublist(0, takeTopCount);
  }
}

///排序
class SortByTransform extends DataTransform {
  List<String> sortFields;
  Order order;

  int takeTopCount;

  SortByTransform(
    this.sortFields, {
    this.order = Order.asc,
    this.takeTopCount = -1,
  });

  @override
  List<RawData> transform(List<RawData> input) {
    if (sortFields.isEmpty) {
      return input;
    }
    input.sort((a, b) {
      for (var key in sortFields) {
        var av = a.get2(key);
        var bv = b.get2(key);
        var c = compareValue(av, bv);
        if (c != 0) {
          if (order == Order.desc) {
            c = -1 * c;
          }
          return c;
        }
      }
      return 0;
    });
    if (takeTopCount <= 0 || takeTopCount >= input.length) {
      return input;
    }
    return input.sublist(0, takeTopCount);
  }
}
