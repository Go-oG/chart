import '../bucket_factory.dart';
import '../bucket_splitter.dart';
import '../fixed_num_bucket_splitter.dart';
import '../weighted_event.dart';
import 'linked_bucket_node.dart';
import 'ltweighted_bucket.dart';

class LTDynamicBucketSplitter implements BucketSplitter<LTWeightedBucket, WeightedEvent> {
  FixedNumBucketSplitter<LTWeightedBucket, WeightedEvent> fs = FixedNumBucketSplitter();
  double iterationRate = 0.1;
  int maxIteration = 500;

  @override
  List<LTWeightedBucket> split(BucketFactory<LTWeightedBucket> factory, List<WeightedEvent> data, int threshold) {
    // first split equally
    List<LTWeightedBucket> buckets = fs.split(factory, data, threshold);
    // resize buckets
    LinkedBucketNode head = LinkedBucketNode.fromList(buckets);
    for (var i = getItCount(data.length, threshold); i >= 0; i--) {
      LinkedBucketNode max = findMaxSSE(head)!;
      findMinSSEPair(head, max)!.merge();
      max.split();
    }
    return LinkedBucketNode.toList(head);
  }

  int getItCount(int total, int threshold) {
    int itCount = (total / threshold * iterationRate).toInt();
    if (itCount > maxIteration) {
      itCount = maxIteration;
    } else if (itCount < 1) {
      itCount = 1;
    }
    return itCount;
  }

  static LinkedBucketNode? findMinSSEPair(LinkedBucketNode head, LinkedBucketNode exclude) {
    double minSSE = double.maxFinite;
    LinkedBucketNode? low;
    LinkedBucketNode? end = head.next!.next!.next!;
    while ((end = end!.next) != null) {
      LinkedBucketNode beta = end!.last!;
      LinkedBucketNode alpha = beta.last!;
      if (beta == exclude) {
        continue;
      }
      double sum = alpha.value.sse + beta.value.sse;
      if (sum < minSSE) {
        minSSE = sum;
        low = alpha;
      }
    }
    return low;
  }

  static LinkedBucketNode? findMaxSSE(LinkedBucketNode head) {
    double maxSSE = double.minPositive;
    LinkedBucketNode? max;
    LinkedBucketNode? end = head.end;
    LinkedBucketNode? n2 = head.next!.next!;
    while (n2 != end) {
      LinkedBucketNode n1 = n2!.last!;
      LinkedBucketNode n3 = n2.next!;
      LTWeightedBucket b = n2.value;
      if (b.calcSSE(n1.value, n3.value) > maxSSE && b.size() > 1) {
        maxSSE = b.sse;
        max = n2;
      }
      n2 = n2.next;
    }
    return max;
  }
}
