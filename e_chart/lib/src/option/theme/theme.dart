import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///全局的主题配置
class ChartTheme {
  ///该列表必须至少有一个
  final List<Color> colors;

  final Color? backgroundColor;
  final LabelTheme labelStyle;

  final LabelTheme title;

  final LabelTheme subTitle;

  final LabelTheme mark;

  final LabelTheme legend;

  ///通用组件主题
  final AreaStyle tooltipTheme;
  final MarkPointTheme markPointTheme;

  ///坐标轴主题
  final AxisTheme normalAxisTheme;
  final AxisTheme categoryAxisTheme;

  final AxisTheme valueAxisTheme;

  final AxisTheme logAxisTheme;

  final AxisTheme timeAxisTheme;

  const ChartTheme({
    this.colors = const [
      Color(0xFF63B0F2),
      Color(0xFF07F29C),
      Color(0xFF7F6CC4),
      Color(0xFF4BA47E),
      Color(0xFFF25C05),
      Color(0xFFF3BA17),
      Color(0xFFF36261),
    ],
    this.backgroundColor,
    this.labelStyle = const LabelTheme(textColor: Color(0xDD000000), textSize: 13),
    this.title = const LabelTheme(textColor: Color(0xFF464646), textSize: 15),
    this.subTitle = const LabelTheme(textColor: Color(0xFF464646), textSize: 13),
    this.mark = const LabelTheme(textColor: Color(0xFFEEEEEE), textSize: 13),
    this.legend = const LabelTheme(textColor: Color(0xFF333333), textSize: 15),

    ///通用组件主题
    this.tooltipTheme = const AreaStyle(),
    this.markPointTheme = const MarkPointTheme(),

    ///坐标轴主题
    this.normalAxisTheme = const AxisTheme(),
    this.categoryAxisTheme = const AxisTheme(),
    this.valueAxisTheme = const AxisTheme(),
    this.logAxisTheme = const AxisTheme(),
    this.timeAxisTheme = const AxisTheme(),
  });

  AreaStyle getAreaStyle(int index) {
    return AreaStyle(color: getColor(index));
  }

  Color getColor(int index) {
    return colors[index % colors.length];
  }
}
