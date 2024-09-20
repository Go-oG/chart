import '../../ds_algorithm.dart';
import '../bucket.dart';
import '../weighted_event.dart';
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
  LTWeightedBucket newBucketFromEvent(OrderData e) {
    return LTWeightedBucket.of(e as WeightEvent);
  }
}
