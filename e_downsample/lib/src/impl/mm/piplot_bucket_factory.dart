import 'package:e_downsample/src/impl/mm/piplot_bucket.dart';

import '../../event.dart';
import '../bucket_factory.dart';

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
  PIPlotBucket newBucketFromEvent(Event e) {
    return PIPlotBucket.of(e);
  }
}
