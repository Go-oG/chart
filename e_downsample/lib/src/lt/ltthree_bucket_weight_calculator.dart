import '../weighted_event.dart';
import 'ltweight_calculator.dart';
import 'ltweighted_bucket.dart';
import 'triangle.dart';

class LTThreeBucketWeightCalculator implements LTWeightCalculator {
  @override
  void calcWeight(Triangle triangle, List<LTWeightedBucket> buckets) {
    for (int i = 1; i < buckets.length - 1; i++) {
      LTWeightedBucket bucket = buckets[i];
      WeightEvent last = buckets[i - 1].select()[0];
      WeightEvent next = buckets[i + 1].average();
      for (int j = 0; j < bucket.size(); j++) {
        WeightEvent? curr = bucket.get(j);
        triangle.calc2(last, curr, next);
      }
    }
  }
}
