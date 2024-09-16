
import '../fixed_num_bucket_splitter.dart';
import '../weighted_event.dart';
import 'lta_algorithm.dart';
import 'ltd_dynamic_bucket_splitter.dart';
import 'lto_one_bucket_weight_calculator.dart';
import 'ltthree_bucket_weight_calculator.dart';
import 'ltweighted_bucket.dart';
import 'ltweighted_bucket_factory.dart';

class LTABuilder {
  static final S_FIXED = FixedNumBucketSplitter<LTWeightedBucket, WeightedEvent>();
  static final S_DYNAMIC = LTDynamicBucketSplitter();
  static final ONE_BUCKET = LTOneBucketWeightCalculator();
  static final THREE_BUCKET = LTThreeBucketWeightCalculator();

  late final LTAlgorithm lta;

  LTABuilder() {
    lta = LTAlgorithm();
    lta.setBucketFactory(LTWeightedBucketFactory());
  }

  LTABuilder fixed() {
    lta.setSpliter(S_FIXED);
    return this;
  }

  LTABuilder dynamic() {
    lta.setSpliter(S_DYNAMIC);
    return this;
  }

  LTABuilder oneBucket() {
    lta.wcalc = ONE_BUCKET;
    return this;
  }

  LTABuilder threeBucket() {
    lta.wcalc = (THREE_BUCKET);
    return this;
  }

  LTAlgorithm build() {
    return lta;
  }
}
