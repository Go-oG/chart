import '../event.dart';
import 'bucket.dart';

interface class BucketFactory<B extends Bucket> {
  B newBucket() {
    throw Error();
  }

  B newBucketFromSize(int size) {
    throw Error();
  }

  B newBucketFromEvent(Event e) {
    throw Error();
  }

}
