import '../ds_algorithm.dart';

interface class Bucket {
  void selectInto(List<OrderData> result) {
    throw Error();
  }

  void add(OrderData e) {
    throw Error();
  }
}

interface class BucketFactory<B extends Bucket> {
  B newBucket() {
    throw Error();
  }

  B newBucketFromSize(int size) {
    throw Error();
  }

  B newBucketFromEvent(OrderData e) {
    throw Error();
  }
}
