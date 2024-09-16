import 'package:e_downsample/src/event.dart';

import 'mm_bucket.dart';

class PIPlotBucket extends MMBucket {
  PIPlotBucket();

  PIPlotBucket.fromSize(int size) : super();

  PIPlotBucket.of(super.e) : super.of();

  @override
  void selectInto(List<Event> result) {
    List<Event> temp = [];
    super.selectInto(temp);
    Set<Event> set = <Event>{};
    if (temp.isNotEmpty) {
      set.add(events[0]);
      set.addAll(temp);
      set.add(events.last);
    }
    result.addAll(set);
  }
}
