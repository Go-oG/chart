import 'dart:core';

import '../weighted_event.dart';
import 'ltweighted_bucket.dart';

class LinkedBucketNode {
  LinkedBucketNode? last;
  LinkedBucketNode? next;
  LinkedBucketNode? end;

  late LTWeightedBucket value;
  int size = 0;

  LinkedBucketNode(this.size);

  LinkedBucketNode.of(this.value);

  LinkedBucketNode split() {
    int size = value.size();
    if (size < 2) {
      return this;
    }
    LTWeightedBucket b0 = LTWeightedBucket.ofSize(size ~/ 2);
    LTWeightedBucket b1 = LTWeightedBucket.ofSize(size - size ~/ 2);
    for (int i = 0; i < size; i++) {
      (i < size / 2 ? b0 : b1).add(value.get(i)!);
    }
    LinkedBucketNode n0 = LinkedBucketNode.of(b0);
    LinkedBucketNode n1 = LinkedBucketNode.of(b1);
    replace(this, n0);
    insert(n0, n1);
    return n1;
  }

  LinkedBucketNode merge() {
    var next = this.next;
    if (next == null) {
      return this;
    }
    LTWeightedBucket m = LTWeightedBucket.ofSize(value.size() + next.value.size());
    for (WeightEvent? e in value.events) {
      m.add(e!);
    }
    for (WeightEvent? e in next.value.events) {
      m.add(e!);
    }
    LinkedBucketNode n = LinkedBucketNode.of(m);
    LinkedBucketNode? tail = next.next;
    concat(last!, n, tail);
    return n;
  }

  static LinkedBucketNode fromList(List<LTWeightedBucket> arr) {
    LinkedBucketNode head = LinkedBucketNode(arr.length);
    LinkedBucketNode last = head;
    for (int i = 0; i < arr.length; i++) {
      LinkedBucketNode node = LinkedBucketNode.of(arr[i]);
      head.end = node;
      node.last = last;
      last.next = node;
      last = node;
    }
    return head;
  }

  static List<LTWeightedBucket> toList(LinkedBucketNode head) {
    List<LTWeightedBucket> arr = [];
    LinkedBucketNode? node = head.next;
    while (node != null) {
      arr.add(node.value);
      node = node.next;
    }
    return arr;
  }

  static void insert(LinkedBucketNode node, LinkedBucketNode append) {
    LinkedBucketNode? next = node.next;
    node.next = append;
    append.last = node;
    append.next = next;
    if (next != null) {
      next.last = append;
    }
  }

  static void replace(LinkedBucketNode node, LinkedBucketNode rep) {
    LinkedBucketNode? next = node.next;
    LinkedBucketNode? last = node.last;
    node.last = null;
    node.next = null;
    last?.next = rep;
    rep.last = last;
    rep.next = next;
    if (next != null) {
      next.last = rep;
    }
  }

  static void concat(LinkedBucketNode head, LinkedBucketNode node, LinkedBucketNode? tail) {
    head.next = node;
    node.last = head;
    node.next = tail;
    if (tail != null) {
      tail.last = node;
    }
  }
}
