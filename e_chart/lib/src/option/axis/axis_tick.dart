import 'dart:math';

import 'package:e_chart/e_chart.dart';

class AxisTick {
  final bool show;
  final bool inside;
  final MainTick? tick;
  final MinorTick? minorTick;

  const AxisTick({
    this.show = true,
    this.inside = true,
    this.tick = const MainTick(),
    this.minorTick,
  });

  AxisTick copy({
    bool? show,
    bool? inside,
    MainTick? tick,
    MinorTick? minorTick,
  }) {
    return AxisTick(
      show: show ?? this.show,
      inside: inside ?? this.inside,
      tick: tick ?? this.tick,
      minorTick: minorTick ?? this.minorTick,
    );
  }

  AxisTick.of({
    this.show = true,
    this.inside = true,
    this.tick,
    this.minorTick,
  });

  double getMaxTickSize() {
    return max(getTickSize(), getMinorSize());
  }

  double getTickSize() {
    if (!show) {
      return 0;
    }
    var tick = this.tick;
    if (tick == null || !tick.show) {
      return 0;
    }
    return tick.length.toDouble();
  }

  double getMinorSize() {
    if (!show) {
      return 0;
    }
    var tick = minorTick;
    if (tick == null || !tick.show) {
      return 0;
    }
    return tick.length.toDouble();
  }

  @override
  int get hashCode {
    return Object.hash(show, inside, tick, minorTick);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is AxisTick &&
        other.show == show &&
        other.inside == inside &&
        other.tick == tick &&
        other.minorTick == minorTick;
  }
}
