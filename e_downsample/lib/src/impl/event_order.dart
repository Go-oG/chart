import 'dart:core';

import '../event.dart';

abstract class EventOrder {
  static final timeAsc = _ByTimeAscOrder();
  static final valueAsc = _ByValueAscOrder();
  static final valueDesc = _ByValueDescOrder();
  static final valueAbsAsc = _ByValueAbsAscOrder();
  static final valueAbsDesc = _ByValueAbsDescOrder();

  int comparator(Event? a, Event? b);
}

final class _ByTimeAscOrder extends EventOrder {
  @override
  int comparator(Event? e1, Event? e2) {
    if (e1 == null && e2 == null) {
      return 0;
    }
    if (e1 == null) {
      return -1;
    }
    if (e2 == null) {
      return 1;
    }
    return e1.getTime() < e2.getTime() ? -1 : 1;
  }
}

final class _ByValueAscOrder extends EventOrder {
  @override
  int comparator(Event? e1, Event? e2) {
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
}

final class _ByValueDescOrder extends EventOrder {
  @override
  int comparator(Event? e1, Event? e2) {
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
}

final class _ByValueAbsAscOrder extends EventOrder {
  @override
  int comparator(Event? e1, Event? e2) {
    if (e1 == null && e2 == null) {
      return 0;
    } else if (e1 == null) {
      return -1;
    } else if (e2 == null) {
      return 1;
    }
    return (e1.getValue().abs()) < (e2.getValue().abs()) ? -1 : 1;
  }
}

final class _ByValueAbsDescOrder extends EventOrder {
  @override
  int comparator(Event? e1, Event? e2) {
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
}
