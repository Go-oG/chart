import 'dart:core';

import '../ds_algorithm.dart';

typedef OrderSort = int Function(OrderData? e1, OrderData? e2);

int orderAsc(OrderData? e1, OrderData? e2) {
  if (e1 == null && e2 == null) {
    return 0;
  }
    if (e1 == null) {
      return -1;
    }
    if (e2 == null) {
      return 1;
    }
  return e1.getOrder() < e2.getOrder() ? -1 : 1;
}

int valueAsc(OrderData? e1, OrderData? e2) {
  if (e1 == null && e2 == null) {
    return 0;
    }
    if (e1 == null) {
      return -1;
    }
    if (e2 == null) {
      return 1;
    }
    return e1.getValue() < e2.getValue() ? -1 : 1;
  }

int valueDesc(OrderData? e1, OrderData? e2) {
  if (e1 == null && e2 == null) {
    return 0;
    }
    if (e1 == null) {
      return -1;
    }
    if (e2 == null) {
      return 1;
    }
    return e1.getValue() < e2.getValue() ? 1 : -1;
  }

int valueAbsAsc(OrderData? e1, OrderData? e2) {
  if (e1 == null && e2 == null) {
    return 0;
    } else if (e1 == null) {
      return -1;
    } else if (e2 == null) {
      return 1;
    }
    return (e1.getValue().abs()) < (e2.getValue().abs()) ? -1 : 1;
  }

int valueAbsDesc(OrderData? e1, OrderData? e2) {
  if (e1 == null && e2 == null) {
    return 0;
    }
    if (e1 == null) {
      return -1;
    }
    if (e2 == null) {
      return 1;
    }
    return (e1.getValue().abs()) < (e2.getValue().abs()) ? 1 : -1;
  }
