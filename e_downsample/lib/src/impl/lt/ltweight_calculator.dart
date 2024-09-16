import 'ltweighted_bucket.dart';
import 'triangle.dart';

interface class LTWeightCalculator {
  void calcWeight(Triangle triangle, List<LTWeightedBucket> buckets) {
    throw Error();
  }
}
