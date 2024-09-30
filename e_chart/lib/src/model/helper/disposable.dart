import 'package:flutter/material.dart';

mixin class Disposable {
  bool _disposeFlag = false;

  bool get isDispose => _disposeFlag;

  final List<VoidCallback> _disposeListener = [];

  void addDisposeListener(VoidCallback listener) {
    _disposeListener.add(listener);
  }

  void removeDisposeListener(VoidCallback listener) {
    _disposeListener.remove(listener);
  }

  @mustCallSuper
  void dispose() {
    _disposeFlag = true;
    for (var item in _disposeListener) {
      item.call();
    }
    _disposeListener.clear();
  }
}
