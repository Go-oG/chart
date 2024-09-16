import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/widget_adapter.dart';
import 'package:flutter/material.dart';
import '../component/title/title_view.dart';
import 'render/render_root.dart';

class Chart extends StatefulWidget {
  final ChartOption option;

  const Chart(this.option, {super.key});

  @override
  State<StatefulWidget> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late ChartOption option;
  final ValueNotifier<ToolTipMenu?> _toolTipNotifier = ValueNotifier(null);
  late WidgetBridge _widgetBridge;
  @override
  void initState() {
    super.initState();
    option = widget.option;
    _widgetBridge = WidgetBridge(toolTipNotifier: _toolTipNotifier);
  }

  @override
  void dispose() {
    _toolTipNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    option = widget.option;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> wl = [];
    wl.add(LegendView(option: option));
    wl.add(Expanded(child: _buildContent(option)));
    if (wl.length > 1) {
      var legend = option.legend;
      if (legend != null && legend.mainAlign == Align2.end) {
        wl = List.from(wl.reversed);
      }
    }
    Widget title = ChildTitleView(option);
    var tt = option.title;
    if (tt != null && tt.mainAlign == Align2.end) {
      wl.add(title);
    } else {
      wl.insert(0, title);
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: wl,
      ),
    );
  }

  Widget _buildContent(ChartOption option) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _InnerChart(option, _widgetBridge),
        ValueListenableBuilder(
            valueListenable: _toolTipNotifier,
            builder: (ctx, menu, child) {
              if (menu == null) {
                return const SizedBox(width: 0, height: 0);
              }
              return Positioned(left: menu.globalOffset.dx, top: menu.globalOffset.dy, child: ToolTipView(menu: menu));
            })
      ],
    );
  }
}

///==================Content==============
class _InnerChart extends StatefulWidget {
  final WidgetBridge widgetAdapter;
  final ChartOption option;

  const _InnerChart(this.option, this.widgetAdapter, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InnerChartState();
  }
}

class _InnerChartState extends State<_InnerChart> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
        child: _InnerWidget(widget.option, this, widget.widgetAdapter));
  }
}

class _InnerWidget extends LeafRenderObjectWidget {
  final ChartOption option;

  final TickerProvider tickerProvider;

  final WidgetBridge widgetAdapter;

  const _InnerWidget(this.option, this.tickerProvider, this.widgetAdapter);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRoot(option, tickerProvider, widgetAdapter);
  }

  @override
  void updateRenderObject(BuildContext context, RenderRoot renderObject) {
    renderObject.onUpdateRender(option, tickerProvider);
  }

}
