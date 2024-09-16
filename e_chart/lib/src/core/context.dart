import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/chart_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:e_chart/src/action/action_dispatcher.dart' as ac;

///整个图表的上下文；一个Context 对应一个图表实例
///包含所有的配置、图形实例、动画、手势等
///================================
///每个Context都包含
///[TickerProvider]、[GestureDispatcher]、[AnimationManager]、[EventDispatcher]、[ac.ActionDispatcher]等核心组件
///除此之外 Context 还负责整个运行组件事件的处理
class Context with Disposable {
  ChartOption get option => _option!;
  ChartOption? _option;

  ///这里不将其暴露出去是为了能更好的管理动画的生命周期
  TickerProvider? _provider;

  GestureDispatcher get gestureDispatcher => _gestureDispatcher;
  final GestureDispatcher _gestureDispatcher = GestureDispatcher();

  AnimateManager get animateManager => _animateManager;
  late final AnimateManager _animateManager;

  EventDispatcher get eventDispatcher => _eventDispatcher;
  final EventDispatcher _eventDispatcher = EventDispatcher();

  ac.ActionDispatcher get actionDispatcher => _actionDispatcher;
  final ac.ActionDispatcher _actionDispatcher = ac.ActionDispatcher();

  final ValueNotifier2<ToolTipMenu?> tooltipNotifier = ValueNotifier2(null);

  double devicePixelRatio;
  late DataManager dataManager;
  late ViewManager viewManager;

  Context(this._option, TickerProvider provider, [this.devicePixelRatio = 1]) {
    _provider = provider;
    _animateManager = AnimateManager(provider);

    ///绑定事件
    option.eventCall?.forEach((key, value) {
      for (var c in value) {
        _eventDispatcher.addCall(key, c);
      }
    });
    ///创建数据管理和视图管理器
    dataManager = DataManager();
    dataManager.parse(this, option.coordList, option.geoms);

    viewManager = ViewManager();
    viewManager.parse(this, option);
    chartScope.addContext(this);
  }

  ///更新TickerProvider
  set tickerProvider(TickerProvider p) {
    if (p == _provider) {
      return;
    }
    _provider = p;
    _animateManager.updateTickerProvider(p);
  }

  ///分配索引
  void allocateIndex() {
    //给Geom 分配索引
    //同时包含了样式索引
    // int styleIndex = 0;
    // each(option.series, (series, i) {
    //   series.seriesIndex = i;
    //   styleIndex += series.onAllocateStyleIndex(styleIndex);
    // });
  }

  ///====生命周期函数=====
  void attach() {
    viewManager.rootView?.attachToWindow();
    allocateIndex();
  }

  void detach() {
    viewManager.rootView?.detachFromWindow();
  }

  @override
  void dispose() {
    chartScope.remove(option);
    chartScope.remove2(this);
    tooltipNotifier.dispose();
    viewManager.dispose();
    dataManager.dispose();
    _animateManager.dispose();
    _eventDispatcher.dispose();
    _actionDispatcher.dispose();
    _gestureDispatcher.dispose();
    _option = null;
    _provider = null;
    super.dispose();
  }

  ///=======手势监听处理===============
  void addGesture(ChartGesture gesture) {
    _gestureDispatcher.addGesture(gesture);
  }

  void removeGesture(ChartGesture? gesture) {
    _gestureDispatcher.removeGesture(gesture);
  }

  ///=========动画管理==================

  AnimationController boundedAnimation(AnimateOption props, [bool useUpdate = false]) {
    return _animateManager.bounded(props, useUpdate: useUpdate);
  }

  AnimationController unboundedAnimation() {
    return _animateManager.unbounded();
  }

  void removeAnimate(AnimationController? c, [bool autoCancel = true]) {
    if (c == null) {
      return;
    }
    _animateManager.remove(c, autoCancel);
  }

  void addAnimateToQueue(List<AnimationNode> nodes) {
    _animateManager.addAnimators(nodes);
  }

  List<AnimationNode> getAndResetAnimateQueue() {
    return _animateManager.getAndRestAnimatorQueue();
  }

  ///========Action分发监听============

  void addActionCall(Fun2<ChartAction, bool> call) {
    _actionDispatcher.addCall(call);
  }

  void removeActionCall(Fun2<ChartAction, bool> call) {
    _actionDispatcher.removeCall(call);
  }

  void dispatchAction(ChartAction action) {
    _actionDispatcher.dispatch(action);
  }

  ///=======Event分发和监听===============
  void addEventCall(EventType type, VoidFun1<ChartEvent>? call) {
    if (call == null) {
      return;
    }
    _eventDispatcher.addCall(type, call);
  }

  void removeEventCall(VoidFun1<ChartEvent>? call) {
    if (call == null) {
      return;
    }
    _eventDispatcher.removeCall(call);
  }

  void removeEventCall2(EventType type, VoidFun1<ChartEvent>? call) {
    if (call == null) {
      return;
    }
    _eventDispatcher.removeCall2(type, call);
  }

  void dispatchEvent(ChartEvent event) {
    if (_eventDispatcher.hasEventListener(event.eventType)) {
      _eventDispatcher.dispatch(event);
    }
  }

  bool hasEventListener(EventType? type) {
    return _eventDispatcher.hasEventListener(type);
  }

  ///==========其它组件相关的方法===========
  void updateTooltip(ToolTipMenu? toolTip) {
    tooltipNotifier.value = toolTip;
  }
}
