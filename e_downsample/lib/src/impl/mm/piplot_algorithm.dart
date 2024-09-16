import 'package:e_downsample/src/event.dart';
import 'package:e_downsample/src/impl/mm/piplot_bucket_factory.dart';
import 'package:meta/meta.dart';

import '../bucket_based_algorithm.dart';
import '../fixed_time_bucket_splitter.dart';
import 'piplot_bucket.dart';

class PIPlotAlgorithm extends BucketBasedAlgorithm<PIPlotBucket, Event> {

  PIPlotAlgorithm() {
    setBucketFactory(PIPlotBucketFactory());
    setSpliter(FixedTimeBucketSplitter<PIPlotBucket, Event>());
  }

  @protected
  @override
  List<Event> prepare(List<Event> data) {
    return data;
  }

  @protected
  @override
  void beforeSelect(List<PIPlotBucket> buckets, int threshold) {}
}
