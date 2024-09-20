import '../../ds_algorithm.dart';
import '../bucket.dart';
import 'piplot_bucket.dart';

class PIPlotBucketFactory implements BucketFactory<PIPlotBucket> {
  @override
  PIPlotBucket newBucket() {
    return PIPlotBucket();
  }

  @override
  PIPlotBucket newBucketFromSize(int size) {
    return PIPlotBucket();
  }

  @override
  PIPlotBucket newBucketFromEvent(OrderData e) {
    return PIPlotBucket.of(e);
  }
}
