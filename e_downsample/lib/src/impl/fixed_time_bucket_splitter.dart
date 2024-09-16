import 'dart:core';

import '../event.dart';
import 'bucket.dart';
import 'bucket_factory.dart';
import 'bucket_splitter.dart';

class FixedTimeBucketSplitter<B extends Bucket, E extends Event> implements BucketSplitter<B, E> {
  List<B> split2(BucketFactory<B> factory, List<E> data, int threshold) {
    List<B> buckets = [];
    int start = data[0].getTime();
    int end = data[data.length - 1].getTime();
    int span = end - start;
    double pice = span / threshold;
    double time = start.toDouble();
    int index = -1;
    for (int i = 0; i < data.length; i++) {
      Event e = data[i];
      if (e.getTime() >= time) {
        time += pice;
        index++;
        buckets.add(factory.newBucket());
      }
      buckets[index].add(e);
    }
    return buckets;
  }

  @override
  List<B> split(BucketFactory<B> factory, List<E> data, int threshold) {
    List<B> buckets = [];
    for (int i = 0; i < threshold; i++) {
      buckets.add(factory.newBucket());
    }
    int start = data[0].getTime();
    int end = data[data.length - 1].getTime();
    int span = end - start;
    for (Event e in data) {
      int bindex = (e.getTime() - start) * threshold ~/ span;
      bindex = bindex >= threshold ? threshold - 1 : bindex;
      buckets[bindex].add(e);
    }
    return buckets;
  }
}
