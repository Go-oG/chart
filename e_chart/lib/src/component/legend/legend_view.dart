import 'package:e_chart/src/core/chart_scope.dart';
import 'package:flutter/material.dart';

import '../../../e_chart.dart';

class LegendView extends StatefulWidget {
  final ChartOption option;

  const LegendView({super.key, required this.option});

  @override
  State<StatefulWidget> createState() => LegendViewState();
}

class LegendViewState extends State<LegendView> {
  ListenSubscription<ChartOption>? _addSubscription;
  final ValueNotifier<List<LegendItem>> _notifier = ValueNotifier([]);
  final Map<LegendItem,bool> legendMap = {};

  @override
  void initState() {
    super.initState();
    _addSubscription = chartScope.listenContextAdd((op) {
      if (op == widget.option) {
        var chartContext = chartScope.getContext(op);
        if (chartContext == null) {
          return;
        }
        chartContext.addEventCall(EventType.legendScroll, _onLegendEvent);
        chartContext.addEventCall(EventType.legend, _onLegendEvent);
      }
    });
  }

  @override
  void dispose() {
    _notifier.dispose();
    var context = chartScope.getContext(widget.option);
    context?.removeEventCall2(EventType.legendScroll, _onLegendEvent);
    context?.removeEventCall2(EventType.legend, _onLegendEvent);

    _addSubscription?.dispose();
    _addSubscription = null;
    super.dispose();
  }

  void initLegend(Legend legend) {
    var data = legend.data;
    if (data == null || data.isEmpty) {
      return;
    }
    _notifier.value = List.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _notifier,
        builder: (ctx, data, child) {
          var legend = widget.option.legend;
          if (legend == null || !legend.show || data.isEmpty) {
            return const SizedBox(width: 0, height: 0);
          }
          List<Widget> itemList = [];
          var dir = legend.direction == Direction.vertical ? Direction.horizontal : Direction.vertical;
          for (var s in data) {
            Widget w = s.toWidget(dir, legend, (item) {
              handleLegendItemChange(item);
              return false;
            });
            itemList.add(w);
          }
          Widget rw;
          if (legend.direction == Direction.vertical) {
            if (legend.scroll) {
              rw = SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: itemList,
                ),
              );
            } else {
              rw = Wrap(
                direction: Axis.vertical,
                spacing: legend.hGap,
                runSpacing: legend.vGap,
                alignment: legend.hAlign,
                runAlignment: legend.vAlign,
                children: itemList,
              );
            }
          } else {
            if (legend.scroll) {
              rw = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: itemList,
                ),
              );
            } else {
              rw = Wrap(
                direction: Axis.horizontal,
                spacing: legend.vGap,
                runSpacing: legend.hGap,
                alignment: legend.vAlign,
                runAlignment: legend.hAlign,
                children: itemList,
              );
            }
          }
          return Container(
            padding: legend.padding,
            decoration: legend.decoration,
            child: rw,
          );
        });
  }

  void handleLegendItemChange(LegendItem? legendItem) {
    var legend = widget.option.legend;
    var data = legend?.data;
    if (legend == null || data == null) {
      return;
    }
    var select=legendMap[legendItem]??true;
    if (!legend.allowSelectMulti && legendItem != null && select) {
      bool change = false;
      for (var item in data) {
        if (item != legendItem && (legendMap[item]??true)) {
          legendMap[item]=false;
          change = true;
        }
      }
      if (change) {
        setState(() {});
      }
    }
  }

  void _onLegendEvent(ChartEvent event) {
    if (event is LegendScrollEvent) {
      return;
    }
    if (event is LegendEvent) {}
  }
}
