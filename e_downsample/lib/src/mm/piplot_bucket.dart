import '../../ds_algorithm.dart';
import 'mm_bucket.dart';

class PIPlotBucket extends MMBucket {
  PIPlotBucket();

  PIPlotBucket.fromSize(int size) : super();

  PIPlotBucket.of(super.e) : super.of();

  @override
  void selectInto(List<OrderData> result) {
    List<OrderData> temp = [];
    super.selectInto(temp);
    Set<OrderData> set = <OrderData>{};
    if (temp.isNotEmpty) {
      set.add(events[0]);
      set.addAll(temp);
      set.add(events.last);
    }
    result.addAll(set);
  }
}
