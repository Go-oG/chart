import 'dart:async';

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
  StreamSubscription<ChartOption>? _addSubscription;
  final ValueNotifier<List<LegendItem>> _notifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _addSubscription = chartScope.listenAddContext((op) {
      if (op == widget.option) {
        var chartContext = chartScope.getContext(op);
        if (chartContext == null) {
          return;
        }
        chartContext.addEventCall(EventType.legendScroll, _onLegendEvent);
        chartContext.addEventCall(EventType.legendInverseSelect, _onLegendEvent);
        chartContext.addEventCall(EventType.legendSelectAll, _onLegendEvent);
        chartContext.addEventCall(EventType.legendUnSelect, _onLegendEvent);
        chartContext.addEventCall(EventType.legendSelectChanged, _onLegendEvent);
      }
    });
  }

  @override
  void dispose() {
    _notifier.dispose();
    var context = chartScope.getContext(widget.option);
    context?.removeEventCall2(EventType.legendScroll, _onLegendEvent);
    context?.removeEventCall2(EventType.legendInverseSelect, _onLegendEvent);
    context?.removeEventCall2(EventType.legendSelectAll, _onLegendEvent);
    context?.removeEventCall2(EventType.legendUnSelect, _onLegendEvent);
    context?.removeEventCall2(EventType.legendSelectChanged, _onLegendEvent);

    _addSubscription?.cancel();
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
    if (!legend.allowSelectMulti && legendItem != null && legendItem.select) {
      bool change = false;
      for (var item in data) {
        if (item != legendItem && item.select) {
          item.select = false;
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
    if (event is LegendInverseSelectEvent) {}
    if (event is LegendSelectAllEvent) {}
    if (event is LegendSelectChangeEvent) {}
    if (event is LegendUnSelectedEvent) {}
  }
}
