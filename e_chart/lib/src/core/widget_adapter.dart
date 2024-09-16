import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

final class WidgetBridge {
  final ValueNotifier<ToolTipMenu?> toolTipNotifier;

  const WidgetBridge({
    required this.toolTipNotifier,
  });
}
