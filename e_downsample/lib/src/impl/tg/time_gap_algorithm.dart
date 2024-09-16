import 'package:e_downsample/src/impl/event_order.dart';

import '../../down_sampling_algorithm.dart';
import '../../event.dart';
import '../weighted_event.dart';

class TimeGapAlgorithm implements DownSamplingAlgorithm {
  final double _rate = 1;

  @override
  List<Event> process(List<Event> data, int threshold) {
    if (data.isEmpty || threshold >= data.length) {
      return data;
    }
    List<Event> result = [];

    List<WeightedEvent> weighted = [];
    double avg = (data.last.getTime() - data.first.getTime()) * 1.0 / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      WeightedEvent we = WeightedEvent(data[i]);
      if (i < data.length - 1) {
        int delta = data[i + 1].getTime() - data[i].getTime();
        we.setWeight(delta - avg);
      }
      weighted.add(we);
    }

    Set<Event> set = <Event>{};
    int max = (threshold * _rate).toInt();
    int multiple = 1024;
    int limit = (double.maxFinite - 2).toInt();
    A:
    while (multiple > 2) {
      for (int i = 0; i < weighted.length; i++) {
        WeightedEvent e = weighted[i];
        double m = e.getWeight() / avg;
        if (m > multiple && m <= limit) {
          set.add(e.getEvent());
          if (i + 1 < weighted.length) {
            set.add(weighted[i + 1].getEvent());
          }
        }
        if (set.length >= max) {
          break A;
        }
      }
      limit = multiple;
      multiple >>= 2;
    }
    result.addAll(set);
    result.sort((a, b) {
      return EventOrder.timeAsc.comparator(a, b);
    });
    return result;
  }
}
