import 'package:e_chart/e_chart.dart';

///变换
class MapTransform extends BaseDataTransform {
  Fun2<RawData, RawData?> mapFun;

  MapTransform(this.mapFun);

  @override
  List<RawData> transform(List<RawData> input) {
    List<RawData> list = [];
    for (var ele in input) {
      var result = mapFun.call(ele);
      if (result != null) {
        if (result == ele) {
          list.add(result);
        } else {
          list.add(ele);
          list.add(result);
        }
      } else {
        list.add(ele);
      }
    }
    return list;
  }
}
