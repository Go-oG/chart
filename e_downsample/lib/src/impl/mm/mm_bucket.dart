import 'package:meta/meta.dart';

import '../../event.dart';
import '../bucket.dart';

class MMBucket implements Bucket {
  @protected
  List<Event> events = [];

  MMBucket();

  MMBucket.of(Event e) {
    events.add(e);
  }

  @override
  void selectInto(List<Event> result) {
    if (events.length <= 1) {
      result.addAll(events);
      return;
    }
    Event? maxEvt;
    Event? minEvt;
    double max = double.minPositive;
    double min = double.maxFinite;
    for (Event e in events) {
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
      bool maxFirst = maxEvt.getTime() < minEvt.getTime();
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
  void add(Event e) {
    events.add(e);
  }
}
