import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///单个坐标系只有一个ToolTip
class ToolTipView extends StatelessWidget {
  final ToolTipMenu menu;

  const ToolTipView({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    final tooltip = menu.toolTip;
    var constraints = BoxConstraints(
        minWidth: tooltip.minWidth ?? 0,
        maxWidth: tooltip.maxWidth ?? 300,
        minHeight: tooltip.minHeight ?? 0,
        maxHeight: tooltip.maxHeight ?? 700);

    return Container(
      constraints: constraints,
      padding: tooltip.padding,
      decoration: tooltip.decoration,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTitle(context, menu.title, menu.titleStyle),
            ...buildItemList(tooltip, menu.itemList)
          ],
        ),
      ),
    );
  }

  Widget buildTitle(BuildContext context, DynamicText? title, LabelStyle? style) {
    if (title == null) {
      return const SizedBox(width: 0, height: 0);
    }
    return (style ?? const LabelStyle()).toWidget(title);
  }

  List<Widget> buildItemList(ToolTip tooltip, List<MenuItem> menuList) {
    List<Widget> list = [];
    var builder = tooltip.itemBuilder;
    menuList.each((data, index) {
      if (builder != null) {
        list.add(builder.call(data, index));
      } else {
        list.add(_buildItem(tooltip, data, index));
      }
    });
    return list;
  }

  Widget _buildItem(ToolTip tooltip, MenuItem item, int index) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8))),
          item.title.toWidget(const TextStyle(fontSize: 15)),
          const Expanded(child: SizedBox()),
          if (item.desc != null) item.desc!.toWidget(const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

}
