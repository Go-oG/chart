
import '../bucket_splitter.dart';
import '../weighted_event.dart';
import 'lta_algorithm.dart';
import 'ltd_dynamic_bucket_splitter.dart';
import 'lto_one_bucket_weight_calculator.dart';
import 'ltthree_bucket_weight_calculator.dart';
import 'ltweighted_bucket.dart';
import 'ltweighted_bucket_factory.dart';

class LTABuilder {
  static final _sFixed = FixedNumBucketSplitter<LTWeightedBucket, WeightEvent>();
  static final _sDynamic = LTDynamicBucketSplitter();
  static final _oneBucket = LTOneBucketWeightCalculator();
  static final _threeBucket = LTThreeBucketWeightCalculator();

  late final LTAlgorithm lta;

  LTABuilder() {
    lta = LTAlgorithm();
    lta.setBucketFactory(LTWeightedBucketFactory());
  }

  LTABuilder fixed() {
    lta.setSplitter(_sFixed);
    return this;
  }

  LTABuilder dynamic() {
    lta.setSplitter(_sDynamic);
    return this;
  }

  LTABuilder oneBucket() {
    lta.wcalc = _oneBucket;
    return this;
  }

  LTABuilder threeBucket() {
    lta.wcalc = _threeBucket;
    return this;
  }

  LTAlgorithm build() {
    return lta;
  }
}
