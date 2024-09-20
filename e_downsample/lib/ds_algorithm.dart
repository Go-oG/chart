library;
export 'src/order_sort.dart';


import 'src/order_sort.dart';
import 'src/lt/lta_builder.dart';
import 'src/mm/mm_algorithm.dart';
import 'src/mm/piplot_algorithm.dart';
import 'src/weighted_event.dart';

interface class OrderData<T> {
  num getOrder() {
    throw Error();
  }

  double getValue() {
    throw Error();
  }

}

interface class DownSamplingAlgorithm {
  List<OrderData> process(List<OrderData> data, int threshold) {
    throw Error();
  }
}

class DSAlgorithms implements DownSamplingAlgorithm {
  late final DownSamplingAlgorithm _delegate;

  DSAlgorithms.piplot() {
    _delegate = PIPlotAlgorithm();
  }

  DSAlgorithms.lttb() {
    _delegate = LTABuilder().threeBucket().fixed().build();
  }

  DSAlgorithms.ltob() {
    _delegate = LTABuilder().oneBucket().fixed().build();
  }

  DSAlgorithms.ltd() {
    _delegate = LTABuilder().threeBucket().dynamic().build();
  }

  DSAlgorithms.maxmin() {
    _delegate = MMAlgorithm();
  }

  @override
  List<OrderData> process(List<OrderData> data, int threshold) {
    return _delegate.process(data, threshold);
  }
}

class MixedAlgorithm implements DownSamplingAlgorithm {
  final Map<DownSamplingAlgorithm, double> _map = {};

  void add(DownSamplingAlgorithm da, double rate) {
    _map[da] = rate;
  }

  @override
  List<OrderData> process(List<OrderData> data, int threshold) {
    if (_map.isEmpty) {
      return data;
    }
    Set<OrderData> set = <OrderData>{};
    for (DownSamplingAlgorithm da in _map.keys) {
      List<OrderData> subList = da.process(data, (threshold * _map[da]!).toInt());
      set.addAll(subList);
    }
    List<OrderData> result = [];
    result.addAll(set);
    result.sort(orderAsc);
    return result;
  }
}

class TimeGapAlgorithm implements DownSamplingAlgorithm {
  final double _rate = 1;

  @override
  List<OrderData> process(List<OrderData> data, int threshold) {
    if (data.isEmpty || threshold >= data.length) {
      return data;
    }
    List<OrderData> result = [];

    List<WeightEvent> weighted = [];
    double avg = (data.last.getOrder() - data.first.getOrder()) * 1.0 / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      WeightEvent we = WeightEvent(data[i]);
      if (i < data.length - 1) {
        num delta = data[i + 1].getOrder() - data[i].getOrder();
        we.setWeight(delta - avg);
      }
      weighted.add(we);
    }

    Set<OrderData> set = <OrderData>{};
    int max = (threshold * _rate).toInt();
    int multiple = 1024;
    int limit = (double.maxFinite - 2).toInt();
    A:
    while (multiple > 2) {
      for (int i = 0; i < weighted.length; i++) {
        WeightEvent e = weighted[i];
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
    result.sort(orderAsc);
    return result;
  }
}
