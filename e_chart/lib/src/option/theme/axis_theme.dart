import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///坐标轴主题
class AxisTheme {
  final bool showAxisLine;

  final Color axisLineColor;

  final num axisLineWidth;

  final MainTick? tick;
  final MinorTick? minorTick;

  final bool showLabel;

  final Color labelColor;

  final num labelSize;

  final bool showMinorLabel;

  final Color minorLabelColor;

  final num minorLabelSize;

  final bool showSplitLine;

  final num splitLineWidth;

  final List<Color> splitLineColors;

  final bool showSplitArea;

  final List<Color> splitAreaColors;

  const AxisTheme({
    this.showAxisLine = true,
    this.axisLineColor = const Color(0xFF000000),
    this.axisLineWidth = 1,
    this.tick,
    this.minorTick,
    this.showLabel = true,
    this.labelColor = const Color(0xFF000000),
    this.labelSize = 13,
    this.showMinorLabel = false,
    this.minorLabelColor = const Color(0xFF000000),
    this.minorLabelSize = 13,
    this.showSplitLine = false,
    this.splitLineWidth = 1,
    this.splitLineColors = const [Color(0xFFE0E6F1)],
    this.showSplitArea = false,
    this.splitAreaColors = const [
      Color.fromRGBO(250, 250, 250, 0.2),
      Color.fromRGBO(210, 219, 238, 0.2),
    ],
  });

  MainTick? getMainTick() {
    if (tick == null || !tick!.show) {
      return null;
    }
    return tick;
  }

  MinorTick? getMinorTick() {
    if (minorTick == null || !minorTick!.show) {
      return null;
    }
    return minorTick;
  }

  Color? getSplitLineColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (!showSplitLine) {
      return null;
    }
    if (splitLineColors.isNotEmpty) {
      return splitLineColors[index % splitLineColors.length];
    }
    return axisLineColor;
  }

  LineStyle? getSplitLineStyle(int index) {
    Color? color = getSplitLineColor(index);
    if (color != null) {
      return LineStyle(color: color, width: splitLineWidth);
    }
    return null;
  }

  Color? getSplitAreaColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (!showSplitArea) {
      return null;
    }
    if (splitAreaColors.isNotEmpty) {
      return splitAreaColors[index % splitAreaColors.length];
    }
    return Colors.white;
  }

  AreaStyle? getSplitAreaStyle(int index) {
    Color? color = getSplitAreaColor(index);
    if (color != null) {
      return AreaStyle(color: color);
    }
    return null;
  }

  Color? getAxisLineColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (!showAxisLine) {
      Logger.i("不显示该轴");
      return null;
    }
    return axisLineColor;
  }

  LineStyle? getAxisLineStyle(int index) {
    Color? color = getAxisLineColor(index);
    if (color != null) {
      return LineStyle(color: color, width: axisLineWidth);
    }
    return null;
  }
}
