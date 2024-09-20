import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

final chartScope = ChartScope._();

///图表域
///负责持有所有的图表实例
class ChartScope {
  ChartScope._();

  final Map<ChartOption, Context> _contexts = {};

  final BroadcastNotifier<ChartOption> _addNotifier = BroadcastNotifier();

  final BroadcastNotifier<ChartOption> _removeNotifier = BroadcastNotifier();

  ListenSubscription<ChartOption> listenContextAdd(VoidFun1<ChartOption> listener) {
    var result = _addNotifier.listen(listener);
    Set<ChartOption> keySets = _contexts.keys.toSet();
    for (var item in keySets) {
      result.notify(item);
    }
    return result;
  }

  ListenSubscription<ChartOption> listenContextRemoved(VoidFun1<ChartOption> listener) {
    var res = _removeNotifier.listen(listener);
    return res;
  }

  Context getOrCreateContext(ChartOption option, TickerProvider provider, double dp) {
    var context = getContext(option);
    if (context != null) {
      return context;
    }
    context = Context(option, provider, dp);
    Context tmp = context;
    context.addDisposeListener(() {
      remove2(tmp);
    });
    addContext(context);
    return context;
  }

  Context? getContext(ChartOption option) {
    return _contexts[option];
  }

  void addContext(Context? context) {
    if (context == null) {
      return;
    }
    var old = _contexts[context.option];
    if (old == null) {
      _contexts[context.option] = context;
      _addNotifier.notify(context.option);
    }
  }

  void remove(ChartOption option) {
    if (_contexts.remove(option) != null) {
      _removeNotifier.notify(option);
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
      _removeNotifier.notify(context.option);
    }
  }
}
