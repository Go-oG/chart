import 'package:meta/meta.dart';

import '../../ds_algorithm.dart';
import '../base_algorithm.dart';
import '../bucket_splitter.dart';
import 'piplot_bucket.dart';
import 'piplot_bucket_factory.dart';

class PIPlotAlgorithm extends BucketBasedAlgorithm<PIPlotBucket, OrderData> {
  PIPlotAlgorithm() {
    setBucketFactory(PIPlotBucketFactory());
    setSplitter(FixedTimeBucketSplitter<PIPlotBucket, OrderData>());
  }

  @protected
  @override
  List<OrderData> prepare(List<OrderData> data) {
    return data;
  }

  @protected
  @override
  void beforeSelect(List<PIPlotBucket> buckets, int threshold) {}
}
