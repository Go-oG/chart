import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class LabelTheme {
  final Color textColor;
  final double textSize;

  const LabelTheme({
    this.textColor = const Color(0xDD000000),
    this.textSize = 13,
  });

  LabelStyle get style {
    return LabelStyle(textStyle: TextStyle(color: textColor, fontSize: textSize));
  }
}
