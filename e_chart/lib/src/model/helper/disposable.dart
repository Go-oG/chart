import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

mixin class Disposable {
  bool _disposeFlag = false;

  bool get isDispose => _disposeFlag;

  final SafeList<VoidCallback> _disposeListener = SafeList();

  void addDisposeListener(VoidCallback listener) {
    _disposeListener.add(listener);
  }

  void removeDisposeListener(VoidCallback listener) {
    _disposeListener.remove(listener);
  }

  @mustCallSuper
  void dispose() {
    _disposeFlag = true;
    _disposeListener.each((item) {
      item.call();
    });
    _disposeListener.clear();
  }
}
