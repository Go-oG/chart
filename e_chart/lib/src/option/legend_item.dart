import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../component/legend/legend_item_view.dart';

class LegendItem {
  final DynamicText name;
  final CShape symbol;
  final double gap;
  final LabelStyle? textStyle;
  bool select = true;

  LegendItem(
    this.name,
    this.symbol, {
    this.gap = 8,
    this.textStyle,
  });

  LegendItem.empty()
      : name = DynamicText.empty,
        symbol = EmptyShape(),
        gap = 0,
        textStyle = null;

  Widget toWidget(Direction direction, Legend legend, Fun2<LegendItem, bool>? call) {
    return LegendItemView(
      item: this,
      legend: legend,
      call: call,
    );
  }

  @override
  int get hashCode {
    return Object.hash(name, symbol, gap, textStyle);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is LegendItem &&
        other.name == name &&
        other.symbol == symbol &&
        other.gap == gap &&
        other.textStyle == textStyle;
  }
}
