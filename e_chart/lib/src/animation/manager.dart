import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

///全局的动画管理者
///负责管理所有的AnimationController 以及相关联的动画节点
class AnimateManager extends Disposable {
  TickerProvider _provider;

  AnimateManager(this._provider);

  void updateProvider(TickerProvider provider) {
    _provider = provider;
  }

  ///存储已经创建的控制器
  Map<String, AnimationController> _map = {};

  AnimationController bounded(AnimateOption props, {String? key, bool useUpdate = false}) {
    _collate();
    var c = AnimationController(
      vsync: _provider,
      duration: useUpdate ? props.updateDuration : props.duration,
      reverseDuration: useUpdate ? props.updateDuration : props.duration,
      lowerBound: 0,
      upperBound: 1,
      animationBehavior: props.behavior,
    );
    key ??= randomId();
    if (_map.containsKey(key)) {
      _map.remove(key)?.dispose();
    }
    _map[key] = c;
    return c;
  }

  AnimationController unbounded({String? key}) {
    _collate();
    AnimationController c = AnimationController.unbounded(vsync: _provider, duration: const Duration(days: 999));
    key ??= randomId();
    if (_map.containsKey(key)) {
      _map.remove(key)?.dispose();
    }
    _map[key] = c;
    return c;
  }

  void _collate() {
    _map.removeWhere((key, value) => value.isCompleted);
  }

  void remove(AnimationController c, [bool dispose = true]) {
    _map.removeWhere((key, value) => value == c);
    if (dispose) {
      try {
        c.dispose();
      } catch (_) {}
    }
  }

  void removeByKey(String key, [bool dispose = true]) {
    AnimationController? c = _map.remove(key);
    if (c == null) {
      return;
    }
    if (dispose) {
      try {
        c.dispose();
      } catch (_) {}
    }
  }

  void updateTickerProvider(TickerProvider provider) {
    _map.forEach((key, value) {
      value.resync(provider);
    });
  }

  ///取消所有的动画
  void cancelAllAnimator() {
    var map = _map;
    _map = {};
    map.forEach((key, value) {
      try {
        value.dispose();
      } catch (_) {}
    });
  }

  ///存储动画队列
  final SafeList<AnimationNode> _animatorQueue = SafeList();

  static final List<AnimationNode> _emptyList = List.empty(growable: false);

  List<AnimationNode> getAndRestAnimatorQueue() {
    if (_animatorQueue.isEmpty) {
      return _emptyList;
    }
    List<AnimationNode> nodeList = [];
    _animatorQueue.each((value) {
      if (!value.isDispose) {
        nodeList.add(value);
      }
    });
    _animatorQueue.clear();
    return nodeList;
  }

  void addAnimators(List<AnimationNode> nodes) {
    _animatorQueue.addAll(nodes);
  }

  void addAnimator(AnimationNode node) {
    _animatorQueue.add(node);
  }

  void removeAnimator(AnimationNode node) {
    _animatorQueue.remove(node);
  }

  void disposeAnimatorQueue() {
    _animatorQueue.each((value) {
      try {
        value.dispose();
      } catch (e) {
        Logger.e(e);
      }
    });
    _animatorQueue.clear();
  }

  @override
  void dispose() {
    super.dispose();
    cancelAllAnimator();
    disposeAnimatorQueue();
    _animatorQueue.dispose();
  }
}
