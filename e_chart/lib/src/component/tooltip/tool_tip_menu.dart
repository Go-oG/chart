import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ToolTipMenu {
  final ToolTip toolTip;
  final Offset position;
  final Offset globalOffset;
  final DynamicText? title;
  final LabelStyle? titleStyle;
  final List<MenuItem> itemList;

  const ToolTipMenu(
    this.toolTip,
    this.position,
    this.globalOffset,
    this.itemList, {
    this.title,
    this.titleStyle,
  });

  ToolTipMenu copy({
    ToolTip? toolTip,
    Offset? position,
    Offset? globalOffset,
    List<MenuItem>? itemList,
    DynamicText? title,
    LabelStyle? titleStyle,
  }) {
    return ToolTipMenu(
      toolTip ?? this.toolTip,
      position ?? this.position,
      globalOffset ?? this.globalOffset,
      itemList ?? this.itemList,
      title: title ?? this.title,
      titleStyle: titleStyle ?? this.titleStyle,
    );
  }
}

class MenuItem {
  static final MenuItem empty = MenuItem(DynamicText.empty);
  final DynamicText title;
  final DynamicText? desc;
  const MenuItem(this.title, [this.desc]);
}
