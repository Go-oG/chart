extension NumberExt on num {
  bool equal(num other, [double accuracy = 0.00000001]) {
    return (other - this).abs() <= accuracy;
  }

  String fixStr() {
    return toStringAsFixed(2);
  }
}

extension IntExt on int {
  String padLeft(int width, [String padding = '']) {
    return toString().padLeft(width, padding);
  }

  String padRight(int width, [String fill = '']) {
    return toString().padRight(width, fill);
  }
}
