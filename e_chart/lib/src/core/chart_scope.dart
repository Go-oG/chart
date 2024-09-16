import 'dart:async';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

final chartScope = ChartScope._();

///图表域
///负责持有所有的图表实例
class ChartScope {
  ChartScope._();

  final Map<ChartOption, Context> _contexts = {};

  final BroadcastNotifier<ChartOption> _addNotifier = BroadcastNotifier();

  final BroadcastNotifier<ChartOption> _removeNotifier = BroadcastNotifier();

  ListenSubscription<ChartOption> listenAddContext(VoidFun1<ChartOption> listener) {
   return _addNotifier.listen(listener);
  }

  ListenSubscription<ChartOption> listenRemoveContext(VoidFun1<ChartOption> listener) {
    return _removeNotifier.listen(listener);
  }

  void addContext(Context? context) {
    if (context == null) {
      return;
    }
    var old = _contexts[context.option];
    if (old == null) {
      _contexts[context.option] = context;
      _addNotifier.update(context.option);
    }
  }

  Context? getContext(ChartOption option) {
    return _contexts[option];
  }

  void remove(ChartOption option) {
    if (_contexts.remove(option) != null) {
      _removeNotifier.update(option);
    }
  }

  void remove2(Context context) {
    bool change = false;
    _contexts.removeWhere((k, v) {
      var result = v == context;
      if (result) {
        change = true;
      }
      return result;
    });
    if (change) {
      _removeNotifier.update(context.option);
    }
  }
}
