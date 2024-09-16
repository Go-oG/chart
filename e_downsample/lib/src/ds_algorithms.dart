import 'down_sampling_algorithm.dart';
import 'event.dart';
import 'impl/lt/lta_builder.dart';
import 'impl/mm/mm_algorithm.dart';
import 'impl/mm/piplot_algorithm.dart';

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
  List<Event> process(List<Event> data, int threshold) {
    return _delegate.process(data, threshold);
  }

}
