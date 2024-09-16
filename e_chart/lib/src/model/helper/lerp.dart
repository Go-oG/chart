import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../types.dart';

interface class Lerpable<T> {
  T lerp(T end, double t) {
    throw UnimplementedError();
  }
}

final class _LerpFunGlobal {
  _LerpFunGlobal._();
  static Set<Fun4<dynamic, dynamic, double, dynamic>> lerpFunSet = {};
}

void registerLerpFun(Fun4<dynamic, dynamic, double, dynamic> fun) {
  _LerpFunGlobal.lerpFunSet.add(fun);
}

void unregisterLerpFun(Fun4<dynamic, dynamic, double, dynamic> fun) {
  _LerpFunGlobal.lerpFunSet.remove(fun);
}

T? lerpDynamic<T>(T s, T e, double t) {
  for (var funItem in _LerpFunGlobal.lerpFunSet) {
    try {
      return funItem(s, e, t);
    } catch (_) {}
  }

  if (s is num && e is num) {
    return lerpNum(s, e, t) as T;
  }

  if (s is Lerpable) {
    return s.lerp(e, t) as T;
  }

  if (s is Offset) {
    return lerpOffset(s, e as Offset, t) as T;
  }

  if (s is Size) {
    return lerpSize(s, e as Size, t) as T;
  }
  if (s is Rect) {
    return lerpRect(s, e as Rect, t) as T;
  }

  if (s is Color) {
    return Color.lerp(s, e as Color, t) as T;
  }

  if (s is Duration) {
    return lerpDuration(s, e as Duration, t) as T;
  }
  try {
    return (s as dynamic).lerp(e, t);
  } catch (_) {}
  try {
    return (s as dynamic) + ((e as dynamic) - (s as dynamic)) * t as T;
  } catch (_) {}
  return null;
}

Size lerpSize(Size? a, Size? b, double t) {
  if (a == b) {
    return b ?? Size.zero;
  }
  if (t == 0) {
    return a ?? Size.zero;
  }
  if (t == 1) {
    return b ?? Size.zero;
  }
  return Size.lerp(a, b, t)!;
}

Offset lerpOffset(Offset? a, Offset? b, double t) {
  if (a == b) {
    return b ?? Offset.zero;
  }
  if (t == 0) {
    return a ?? Offset.zero;
  }
  if (t == 1) {
    return b ?? Offset.zero;
  }
  return Offset.lerp(a, b, t)!;
}

Rect lerpRect(Rect? a, Rect? b, double t) {
  if (a == b) {
    return b ?? Rect.zero;
  }
  if (t == 0) {
    return a ?? Rect.zero;
  }
  if (t == 1) {
    return b ?? Rect.zero;
  }
  return Rect.lerp(a, b, t)!;
}

int lerpInt(int? s, int? e, double t) {
  if (s == e || (s?.isNaN ?? false) && (e?.isNaN ?? false)) {
    return s ?? 0;
  }
  s ??= 0;
  e ??= 0;
  return (s + (e - s) * t).round();
}

double lerpNum(num? s, num? e, double t) {
  if (s == e || (s?.isNaN ?? false) && (e?.isNaN ?? false)) {
    return s == null ? 0 : s.toDouble();
  }
  s ??= 0;
  e ??= 0;
  return (s + (e - s) * t);
}
