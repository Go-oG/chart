import 'package:e_downsample/src/event.dart';
import 'package:e_downsample/src/impl/weighted_event.dart';

import '../bucket_factory.dart';
import 'ltweighted_bucket.dart';

class LTWeightedBucketFactory implements BucketFactory<LTWeightedBucket> {
  @override
  LTWeightedBucket newBucket() {
    return  LTWeightedBucket();
  }

  @override
  LTWeightedBucket newBucketFromSize(int size) {
    return LTWeightedBucket.ofSize(size);
  }

  @override
  LTWeightedBucket newBucketFromEvent(Event e) {
    return LTWeightedBucket.of(e as WeightedEvent);
  }
}
