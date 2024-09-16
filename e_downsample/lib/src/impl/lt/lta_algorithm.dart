import 'package:e_downsample/src/event.dart';
import 'package:e_downsample/src/impl/bucket_based_algorithm.dart';
import 'package:e_downsample/src/impl/lt/triangle.dart';
import 'package:meta/meta.dart';

import '../weighted_event.dart';
import 'ltweight_calculator.dart';
import 'ltweighted_bucket.dart';

class LTAlgorithm extends BucketBasedAlgorithm<LTWeightedBucket, WeightedEvent> {
  @protected
  Triangle triangle = Triangle();
  late LTWeightCalculator wcalc;

  LTAlgorithm();

  @protected
  @override
  List<WeightedEvent> prepare(List<Event> data) {
    List<WeightedEvent> result = [];
    for (Event event in data) {
      result.add(WeightedEvent(event));
    }
    return result;
  }

  @protected
  @override
  void beforeSelect(List<LTWeightedBucket> buckets, int threshold) {
    wcalc.calcWeight(triangle, buckets);
  }
}
