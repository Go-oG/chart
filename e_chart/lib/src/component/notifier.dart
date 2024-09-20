
import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';

///对官方ChangeNotifier的改造
class ValueNotifier2<T> with Disposable {
  final List<VoidFun1<T>?> _emptyList = List.empty();
  final bool equalsObject;
  late List<VoidFun1<T>?> _listenerList = _emptyList;

  int _count = 0;
  int _removeCount = 0;
  int _notifyCount = 0;

  T _value;

  set value(T t) {
    if (equalsObject && t == _value) {
      return;
    }
    _value = t;
    notifyListeners();
  }

  T get value => _value;

  ValueNotifier2(this._value, [this.equalsObject = false]);

  void addListener(VoidFun1<T>? listener) {
    if (listener == null) {
      return;
    }
    if (_count == _listenerList.length) {
      if (_count == 0) {
        _listenerList = List.filled(4, null);
      } else {
        final List<VoidFun1<T>?> newList = List.filled(_listenerList.length * 2, null);
        for (int i = 0; i < _count; i++) {
          newList[i] = _listenerList[i];
        }
        _listenerList = newList;
      }
    }
    _listenerList[_count] = listener;
    _count++;
  }

  void removeListener(VoidFun1<T> listener) {
    for (int i = 0; i < _count; i++) {
      var v = _listenerList[i];
      if (v == listener) {
        _listenerList[i] = null;
        _removeCount++;
      }
    }
  }

  void clearListener() {
    _count = 0;
    _listenerList = _emptyList;
    _removeCount = 0;
  }

  void notifyListeners() {
    if (_count <= 0) {
      _count = 0;
      return;
    }
    _notifyCount++;
    var tmpValue = _value;
    _listenerList.each((p0, p1) {
      p0?.call(tmpValue);
    });
    _notifyCount--;
    if (_notifyCount <= 0 && _removeCount > 0) {
      final int newLength = _count - _removeCount;
      if (newLength * 2 <= _listenerList.length) {
        ///长度不满足则直接重新创建一个
        final List<VoidFun1<T>?> newListeners = List<VoidFun1<T>?>.filled(newLength, null);
        int newIndex = 0;
        for (int i = 0; i < _count; i++) {
          final VoidFun1<T>? listener = _listenerList[i];
          if (listener != null) {
            newListeners[newIndex++] = listener;
          }
        }
        _listenerList = newListeners;
      } else {
        ///长度满足则直接进行移位操作(将右边的移动到左边)
        for (int i = 0; i < newLength; i++) {
          var c = _listenerList[i];
          if (c == null) {
            int swapIndex = i + 1;
            while (swapIndex < _listenerList.length && _listenerList[swapIndex] == null) {
              swapIndex += 1;
            }
            _listenerList[i] = _listenerList[swapIndex];
            _listenerList[swapIndex] = null;
          }
        }
      }
      _removeCount = 0;
      _count = newLength;
    }
  }

  bool get hasListeners => _count > 0;

  bool hasListener(VoidFun1<T> listener) {
    for (var item in _listenerList) {
      if (item == listener) {
        return true;
      }
    }
    return false;
  }

  List<VoidFun1<T>?> get listeners => _listenerList;

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    clearListener();
  }
}

class ViewNotifier extends ValueNotifier2<Command> {
  ViewNotifier() : super(Command.none);

  ///通知视图配置发生了变化(包含了数据变化)
  /// 它会触发整个View重新走一遍构造流程
  /// 如果仅仅只是数据发生变化了建议使用 [notifyUpdateData]
  void notifyConfigChange() {
    value = Command.configChange;
  }

  ///通知数据更新
  void notifyUpdateData() {
    value = Command.updateData;
  }

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }
}

class BroadcastNotifier<T> {
  final ValueNotifier2<_NeverEqual<T>> _notifier = ValueNotifier2(_NeverEqual._default());
  final Map<VoidFun1<T>, ListenSubscription<T>> _map = {};

  ListenSubscription<T> listen(VoidFun1<T> listener) {
    var ll = _map.remove(listener);
    if (ll != null) {
      _notifier.removeListener(ll._onCall);
    }
    var result = ListenSubscription<T>._(listener, this);
    _map[listener] = result;
    _notifier.addListener(result._onCall);
    return result;
  }

  void _removeListener(VoidFun1<_NeverEqual<T>>? listener) {
    if (listener == null) {
      return;
    }
    _notifier.removeListener(listener);
  }

  void notify(T tmpValue) {
    _notifier.value = _NeverEqual(tmpValue);
  }

  T? get value {
    var data = _notifier.value;
    if (data.defaultData) {
      return null;
    }
    return data.data;
  }
}

final class ListenSubscription<T> {
  VoidFun1<T>? _listener;
  BroadcastNotifier<T>? _notifier;

  ListenSubscription._(this._listener, this._notifier);

  void _onCall(_NeverEqual<T> value) {
    var data = value.data;
    if (data != null && !value.defaultData) {
      _listener?.call(data);
    }
  }

  void dispose() {
    _notifier?._removeListener(_onCall);
    _listener = null;
    _notifier = null;
  }

  void notify(T? value) {
    if (value == null) {
      return;
    }
    _listener?.call(value);
  }
}

final class _NeverEqual<T> {
  final bool defaultData;
  final T? data;

  _NeverEqual(this.data) : defaultData = false;

  _NeverEqual._default()
      : data = null,
        defaultData = true;

  @override
  bool operator ==(Object other) {
    return false;
  }

  @override
  int get hashCode => data == null ? super.hashCode : data.hashCode;
}

///对图表命令的封装
class Command {
  ///[ChartRender]使用
  static const Command none = Command._(0, runAnimation: false);
  static const Command invalidate = Command._(-10000, runAnimation: false);
  static const Command reLayout = Command._(-10001, runAnimation: true);

  ///[ViewHelper]使用
  static const Command layoutEnd = Command._(-10002, runAnimation: false);
  static const Command layoutUpdate = Command._(-10003, runAnimation: false);

  ///通用
  static const Command configChange = Command._(-10004, runAnimation: true);
  static const Command updateData = Command._(-10005, runAnimation: true);

  ///组件相关
  //Brush
  static const clearBrush = Command._(-10006, runAnimation: false);
  static const hideBrush = Command._(-10007, runAnimation: false);
  static const showBrush = Command._(-10008, runAnimation: false);

  //legend
  static const inverseSelectLegend = Command._(-10009);
  static const selectAllLegend = Command._(-10010);
  static const unselectLegend = Command._(-10011);
  static const legendItemChangeCode = -10012;

  final int code;

  ///是否需要运行动画
  final bool runAnimation;
  final Map<String, dynamic> data;

  Command(
    this.code, {
    this.runAnimation = false,
    this.data = const {},
  }) {
    if (code <= 0) {
      throw ChartError("code must >0");
    }
  }

  static Command buildLegendChange(LegendItem item) {
    return Command._(legendItemChangeCode, data: {"legendItem": item});
  }

  const Command._(this.code, {this.runAnimation = true, this.data = const {}});

  Command copy({bool? runAnimation}) {
    return Command(code, runAnimation: runAnimation ?? this.runAnimation);
  }

  @override
  String toString() {
    return 'Command:$code';
  }

  @override
  int get hashCode {
    return code.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is Command && other.code == code;
  }
}
