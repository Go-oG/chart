import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class ChildTitleView extends StatelessWidget {
  final ChartOption option;

  const ChildTitleView(this.option, {super.key});

  @override
  Widget build(BuildContext context) {
    var title = option.title;
    if (title == null || !title.show) {
      return const SizedBox(width: 0, height: 0);
    }
    List<Widget> wl = [];
    if (title.text.isNotEmpty) {
      wl.add(Text(title.text, style: title.textStyle.textStyle));
    }

    if (title.subText.isNotEmpty) {
      wl.add(Text(title.subText, style: title.subTextStyle.textStyle));
    }

    return Container(
      decoration: title.decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: wl,
      ),
    );
  }
}

