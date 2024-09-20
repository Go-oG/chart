import 'dart:core';

import 'package:meta/meta.dart';

import '../../ds_algorithm.dart';
import '../base_algorithm.dart';
import '../bucket_splitter.dart';
import 'mm_bucket.dart';
import 'mm_bucket_factory.dart';

class MMAlgorithm extends BucketBasedAlgorithm<MMBucket, OrderData> {
  MMAlgorithm() {
    setBucketFactory(MMBucketFactory());
    setSplitter(FixedTimeBucketSplitter<MMBucket, OrderData>());
  }

  @protected
  @override
  List<OrderData> prepare(List<OrderData> data) {
    return data;
  }

  @protected
  @override
  void beforeSelect(List<MMBucket> buckets, int threshold) {}
}
