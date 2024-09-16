import 'dart:core';

import 'package:meta/meta.dart';

import '../../event.dart';
import '../bucket_based_algorithm.dart';
import '../fixed_time_bucket_splitter.dart';
import 'mm_bucket.dart';
import 'mm_bucket_factory.dart';

class MMAlgorithm extends BucketBasedAlgorithm<MMBucket, Event> {
  MMAlgorithm() {
    setBucketFactory(MMBucketFactory());
    setSpliter(FixedTimeBucketSplitter<MMBucket, Event>());
  }

  @protected
  @override
  List<Event> prepare(List<Event> data) {
    return data;
  }

  @protected
  @override
  void beforeSelect(List<MMBucket> buckets, int threshold) {}
}
