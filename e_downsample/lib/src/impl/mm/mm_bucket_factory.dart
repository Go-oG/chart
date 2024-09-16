import 'package:e_downsample/src/impl/bucket_factory.dart';
import '../../event.dart';
import 'mm_bucket.dart';

class MMBucketFactory implements BucketFactory<MMBucket> {
  @override
  MMBucket newBucket() {
    return MMBucket();
  }

  @override
  MMBucket newBucketFromSize(int size) {
    return MMBucket();
  }

  @override
  MMBucket newBucketFromEvent(Event e) {
    return MMBucket.of(e);
  }
}
