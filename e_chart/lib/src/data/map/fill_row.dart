
import 'package:e_chart/e_chart.dart';

///填充行
class FillRowsTransform extends GroupTransform {
  bool fillByGroup;

  FillRowsTransform(List<String> groupBy, List<String> orderBy, [this.fillByGroup = true,]) : super(groupBy: groupBy, orderBy: orderBy);

  @override
  List<RawData> transform(List<RawData> input) {
    var result = super.transform(input);

    ///TODO 待完成
    String? preKey;
    RawData? preData;
    for (var item in result) {
      var key = item.generateKey(super.groupBy);
      if (preKey == null) {
        preKey = key;
        preData = item;
        continue;
      }
      if (key == preKey) {}
    }

    return result;
  }
}
