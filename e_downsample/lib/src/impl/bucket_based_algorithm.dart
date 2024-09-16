import 'dart:core';

import 'package:meta/meta.dart';

import '../down_sampling_algorithm.dart';
import '../event.dart';
import 'bucket.dart';
import 'bucket_factory.dart';
import 'bucket_splitter.dart';

abstract class BucketBasedAlgorithm<B extends Bucket, E extends Event> implements DownSamplingAlgorithm {
  @protected
  late BucketSplitter<B, E> spliter;
  @protected
  late BucketFactory<B> factory;

  @protected
  List<E> prepare(List<Event> data);

  @protected
  void beforeSelect(List<B> buckets, int threshold);

  @override
  List<Event> process(List<Event> events, int threshold) {
    int dataSize = events.length;
    if (threshold >= dataSize || dataSize < 3) {
      return events;
    }

    List<E> preparedData = prepare(events);

    List<B> buckets = spliter.split(factory, preparedData, threshold);

    // calculating weight or something else
    beforeSelect(buckets, threshold);
    List<Event> result = [];
    // select from every bucket
    for (Bucket bucket in buckets) {
      bucket.selectInto(result);
    }
    return result;
  }

  void setSpliter(BucketSplitter<B, E> spliter) {
    this.spliter = spliter;
  }

  void setBucketFactory(BucketFactory<B> factory) {
    this.factory = factory;
  }
}
