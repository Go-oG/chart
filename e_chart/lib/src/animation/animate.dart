import 'dart:async';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

import '../core/index.dart';

/// 图表动画实现
class Animate<T> extends ValueNotifier2<T> {
  AnimateOption get option => _option!;
  AnimateOption? _option;
  AnimationController? _controller;
  Tween2<T>? _tween;
  late bool _allowCross;

  Animate(
    T begin,
    T end, {
    bool allowCross = true,
    AnimateOption option = AnimateOption.normal,
  }) : super(begin) {
    _tween = Tween2(begin, end);
    _allowCross = allowCross;
    _option = option;
  }

  Animate.fromTween(
    Tween2<T> tween, {
    bool allowCross = true,
    AnimateOption option = AnimateOption.normal,
  }) : super(tween.begin) {
    _tween = tween;
    _allowCross = allowCross;
    _option = option;
  }

  final SafeList<VoidCallback> _starListenerList = SafeList();
  final SafeList<VoidCallback> _endListenerList = SafeList();

  bool _hasCallStart = false;
  bool _cancelFlag = false;
  Timer? _waitTimer;

  void start(Context context, [bool useUpdate = false]) {
    if (isDispose) {
      Logger.w("current Object is disposed");
      return;
    }
    var option = _option!;
    var delay = useUpdate ? option.updateDelay : option.delay;
    if (delay.inMilliseconds <= 0) {
      _startInner(context, option, useUpdate);
      return;
    }
    _cancelFlag = true;
    _waitTimer?.cancel();
    _waitTimer = Timer(delay, () {
      _startInner(context, option, useUpdate);
    });
  }

  void _callOnStart() {
    _starListenerList.each((v) {
      try {
        v.call();
      } catch (e) {
        Logger.e(e);
      }
    });
  }

  void _callOnEnd() {
    _endListenerList.each((v) {
      try {
        v.call();
      } catch (e) {
        Logger.e(e);
      }
    });
  }

  void _startInner(Context context, AnimateOption option, [bool useUpdate = false]) {
    var duration = useUpdate ? option.updateDuration : option.duration;
    if (duration.inMilliseconds <= 0) {
      _callOnStart();
      value = _getValue(1);
      _callOnEnd();
      return;
    }

    _hasCallStart = false;
    _cancelFlag = false;
    _controller = context.boundedAnimation(option, useUpdate);
    var curved = CurvedAnimation(parent: _controller!, curve: useUpdate ? option.updateCurve : option.curve);
    curved.addListener(() {
      if (_cancelFlag) {
        stop();
        return;
      }
      if (!_hasCallStart) {
        _hasCallStart = true;
        _callOnStart();
      }
      value = _getValue(curved.value);
    });
    curved.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _callOnEnd();
      }
    });
    _controller?.forward();
  }

  double get process => _controller?.value ?? 0;

  void stop() {
    try {
      _waitTimer?.cancel();
      _waitTimer = null;
      _cancelFlag = true;
      _controller?.stop(canceled: true);
      _controller?.dispose();
    } catch (e) {
      Logger.e(e);
    }
    _controller = null;
    notifyListeners();
  }

  T get begin => (_tween?.begin)!;

  T get end => (_tween?.end)!;

  bool get isAnimating => _controller != null && _controller!.isAnimating;

  bool get isCompleted => _controller != null && _controller!.isCompleted;

  bool get isDismissed => _controller != null && _controller!.isDismissed;

  AnimationStatus get status => _controller?.status ?? AnimationStatus.dismissed;

  void setTween(T begin, T end) {
    _controller?.stop(canceled: false);
    _tween = Tween2(begin, end);
    value = begin;
  }

  void addStartListener(VoidCallback call) {
    _starListenerList.remove(call);
    _starListenerList.add(call);
  }

  void addEndListener(VoidCallback call) {
    _endListenerList.remove(call);
    _endListenerList.add(call);
  }

  void update(double t) {
    value = _getValue(t);
  }

  T _getValue(double t) {
    if (begin == end) {
      return end;
    }
    if (!_allowCross) {
      if (t >= 1) {
        return end;
      }
      if (t <= 0) {
        return begin;
      }
    }
    return _tween!.transform(t);
  }

  @override
  void dispose() {
    super.dispose();
    stop();
    _starListenerList.dispose();
    _endListenerList.dispose();
    _option = null;
    _tween = null;
  }

  @override
  String toString() {
    return '$runtimeType begin:$begin  end:$end';
  }
}

class AnimateOption {
  static const AnimateOption none = AnimateOption(
    delay: Duration.zero,
    updateCurve: Curves.linear,
    updateDuration: Duration.zero,
    updateDelay: Duration.zero,
    curve: Curves.linear,
    behavior: AnimationBehavior.normal,
    threshold: 0,
  );
  static const AnimateOption normal = AnimateOption();

  final List<AnimateType> typeList;
  final List<AnimateType> updateTypeList;
  final List<AnimateType> exitTypeList;

  final Duration duration;
  final Duration updateDuration;
  final Duration exitDuration;

  final Duration delay;
  final Duration updateDelay;
  final Duration exitDelay;

  final Curve curve;
  final Curve updateCurve;
  final Curve exitCurve;

  final AnimationBehavior behavior;

  ///动画的阈值(超过该值将不会执行动画)
  final int threshold;

  const AnimateOption({
    this.typeList = const [],
    this.updateTypeList = const [],
    this.exitTypeList = const [],
    this.duration = const Duration(milliseconds: 1200),
    this.updateDuration = const Duration(milliseconds: 400),
    this.exitDuration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.updateDelay = Duration.zero,
    this.exitDelay = Duration.zero,
    this.curve = Curves.linear,
    this.updateCurve = Curves.linear,
    this.exitCurve = Curves.linear,
    this.threshold = 500,
    this.behavior = AnimationBehavior.normal,
  });

  bool check(LayoutType type, [int count = -1]) {
    if (type == LayoutType.none) {
      return false;
    }
    if (count > 0 && count > threshold && threshold > 0) {
      return false;
    }
    if (type == LayoutType.layout) {
      return duration.inMilliseconds > 0;
    }
    if (type == LayoutType.update) {
      return updateDuration.inMilliseconds > 0;
    }
    return false;
  }

  Duration getDuration(DiffType type, [int count = -1]) {
    if (count > 0 && threshold > 0 && count > threshold) {
      return Duration.zero;
    }
    if (type == DiffType.add) {
      return duration;
    }
    if (type == DiffType.update) {
      return updateDuration;
    }
    return exitDuration;
  }

  Duration getDelay(DiffType type, [int count = -1]) {
    if (count > 0 && threshold > 0 && count > threshold) {
      return Duration.zero;
    }
    if (type == DiffType.add) {
      return delay;
    }
    if (type == DiffType.update) {
      return updateDelay;
    }
    return exitDelay;
  }

  Curve getCurve(DiffType type, [int count = -1]) {
    if (type == DiffType.add) {
      return curve;
    }
    if (type == DiffType.update) {
      return updateCurve;
    }
    return exitCurve;
  }
}
