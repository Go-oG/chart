import '../event.dart';
import 'bucket.dart';
import 'bucket_factory.dart';
import 'bucket_splitter.dart';

class FixedNumBucketSplitter<B extends Bucket, E extends Event> implements BucketSplitter<B, E> {



  @override
  List<B> split(BucketFactory<B> factory, List<E> data, int threshold) {
    int bucketNum = threshold - 2;
    int netSize = data.length - 2;
    int bucketSize = (netSize + bucketNum - 1) ~/ bucketNum;

    List<B?> buckets = [];
    for (int i = 0; i < threshold; i++) {
      buckets.add(null);
    }

    buckets[0] = factory.newBucketFromEvent(data[0]);
    buckets[threshold - 1] = factory.newBucketFromEvent(data[data.length - 1]);
    for (int i = 0; i < bucketNum; i++) {
      buckets[i + 1] = factory.newBucketFromSize(bucketSize);
    }
    double step = netSize * 1.0 / bucketNum;
    double curr = step;
    int bucketIndex = 1;
    for (int i = 1; i <= netSize; i++) {
      buckets[bucketIndex]!.add(data[i]);
      if (i > curr) {
        bucketIndex++;
        curr += step;
      }
    }

    List<B> resultList = [];
    for (var item in buckets) {
      if (item != null) {
        resultList.add(item);
      }
    }

    return resultList;
  }
}
