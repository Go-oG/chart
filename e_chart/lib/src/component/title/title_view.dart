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

class TitleView extends ChartView {
  DynamicText title;
  LabelStyle style;

  late Text2 label;

  TitleView(super.context, this.title, this.style) {
    label = Text2.of(title, style, Offset.zero, pointAlign: Alignment.topLeft);
  }

  @override
  Future<void>  onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) async {
    if (title.isEmpty) {
      setMeasuredDimension(0,0);
      return;
    }
    Size size = title.getTextSize(style.textStyle);
   setMeasuredDimension(size.width, size.height);
  }

  @override
  void onDraw(Canvas2 canvas) {
    label.draw(canvas, mPaint);
  }

  @override
  void onDispose() {
    title = DynamicText.empty;
    style = LabelStyle.empty;
    label = Text2();
    super.onDispose();
  }
}
