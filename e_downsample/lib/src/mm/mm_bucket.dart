import 'package:meta/meta.dart';

import '../../ds_algorithm.dart';
import '../bucket.dart';

class MMBucket implements Bucket {
  @protected
  List<OrderData> events = [];

  MMBucket();

  MMBucket.of(OrderData e) {
    events.add(e);
  }

  @override
  void selectInto(List<OrderData> result) {
    if (events.length <= 1) {
      result.addAll(events);
      return;
    }
    OrderData? maxEvt;
    OrderData? minEvt;
    double max = double.minPositive;
    double min = double.maxFinite;
    for (OrderData e in events) {
      double val = e.getValue();
      if (val > max) {
        maxEvt = e;
        max = e.getValue();
      }
      if (val < min) {
        minEvt = e;
        min = e.getValue();
      }
    }
    if (maxEvt != null && minEvt != null) {
      bool maxFirst = maxEvt.getOrder() < minEvt.getOrder();
      if (maxFirst) {
        result.add(maxEvt);
        result.add(minEvt);
      } else {
        result.add(minEvt);
        result.add(maxEvt);
      }
    } else if (maxEvt == null && minEvt != null) {
      result.add(minEvt);
    } else if (maxEvt != null && minEvt == null) {
      result.add(maxEvt);
    }
  }

  @override
  void add(OrderData e) {
    events.add(e);
  }
}
