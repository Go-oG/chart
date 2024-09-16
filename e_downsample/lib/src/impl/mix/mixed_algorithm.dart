import 'package:e_downsample/src/impl/event_order.dart';

import '../../down_sampling_algorithm.dart';
import '../../event.dart';

class MixedAlgorithm implements DownSamplingAlgorithm {
  final Map<DownSamplingAlgorithm, double> _map = {};

  void add(DownSamplingAlgorithm da, double rate) {
    _map[da] = rate;
  }

  @override
  List<Event> process(List<Event> data, int threshold) {
    if (_map.isEmpty) {
      return data;
    }
    Set<Event> set = <Event>{};
    for (DownSamplingAlgorithm da in _map.keys) {
      List<Event> subList = da.process(data, (threshold * _map[da]!).toInt());
      set.addAll(subList);
    }
    List<Event> result = [];
    result.addAll(set);
    result.sort((a, b) => EventOrder.timeAsc.comparator(a, b));

    return result;
  }
}
