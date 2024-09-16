import '../../shape/style/line_style.dart';
import 'main_tick.dart';

class MinorTick extends MainTick {
  final int splitNumber;

  const MinorTick({
    this.splitNumber = 5,
    super.show,
    super.length,
    super.lineStyle,
    super.interval,
  });

  @override
  MinorTick copy({
    bool? show,
    num? length,
    LineStyle? lineStyle,
    int? interval,
    int? splitNumber,
  }) {
    return MinorTick(
      show: show ?? this.show,
      length: length ?? this.length,
      lineStyle: lineStyle ?? this.lineStyle,
      interval: interval ?? this.interval,
      splitNumber: splitNumber ?? this.splitNumber,
    );
  }

  @override
  int get hashCode {
    return Object.hash(splitNumber, show, length, lineStyle, interval);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MinorTick &&
        other.splitNumber == splitNumber &&
        other.show == show &&
        other.length == length &&
        other.lineStyle == lineStyle &&
        other.interval == interval;
  }
}
