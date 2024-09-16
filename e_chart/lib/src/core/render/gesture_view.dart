import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';

///实现了一个简易的手势识别器
///后续优化
abstract class GestureView extends ChartView {
  final Map<GestureType, bool> _gestureEnableMap = {};

  ChartGesture? _gesture;
  GestureView(super.context, {super.id});

  Pair<Offset, Offset> _lastHover = Pair(Offset.zero, Offset.zero);
  Offset _lastDrag = Offset.zero;
  Direction? _dragDirection;

  Offset _lastLongPress = Offset.zero;
  Direction? _lpDirection;

  @mustCallSuper
  @override
  void onCreate() {
    super.onCreate();
    _initGestureIfNeed();
    enableGesture(GestureType.tap, true);
    enableGesture(GestureType.doubleTap, false);
    enableGesture(GestureType.longPress, false);
    enableGesture(GestureType.hover, isDesktop);
    enableGesture(GestureType.drag, false);
    enableGesture(GestureType.scale, false);
  }

  @override
  void onDispose() {
    _gestureEnableMap.clear();
    context.removeGesture(_gesture);
    _gesture?.dispose();
    _gesture = null;
    super.onDispose();
  }

  void _initGestureIfNeed() {
    var gesture = _gesture;
    if (gesture != null) {
      return;
    }
    gesture = onCreateGesture() ?? CallGesture(hintTouch);
    _gesture = gesture;
    context.removeGesture(gesture);
    context.addGesture(gesture);
  }

  ChartGesture? onCreateGesture() {
    return null;
  }

  bool hintTouch(Offset globalOffset) {
    return globalOffset.dx >= globalLeft &&
        globalOffset.dx <= globalLeft + width &&
        globalOffset.dy >= globalTop &&
        globalOffset.dy <= globalTop + height;
  }

  void enableGesture(GestureType type, bool enable) {
    var old = _gestureEnableMap[type] ?? false;
    if (old == enable) {
      return;
    }
    _gestureEnableMap[type] = enable;
    _initGestureIfNeed();
    var gesture = _gesture!;
    if (type == GestureType.tap) {
      if (enable) {
        gesture.click = (e) {
          onClick(toLocal(e.globalPosition), e.globalPosition);
        };
      } else {
        gesture.click = null;
      }
    }

    if (type == GestureType.doubleTap) {
      if (enable) {
        gesture.doubleClick = (e) {
          onDoubleClick(toLocal(e.globalPosition), e.globalPosition);
        };
      } else {
        gesture.doubleClick = null;
      }
    }

    if (type == GestureType.hover) {
      if (enable) {
        gesture.hoverStart = (e) {
          _lastHover = Pair(toLocal(e.globalPosition), e.globalPosition);
          onHoverStart(_lastHover.first, _lastHover.second);
        };
        gesture.hoverMove = (e) {
          var old = _lastHover;
          Pair<Offset, Offset> of = Pair(toLocal(e.globalPosition), e.globalPosition);
          _lastHover = of;
          onHoverMove(of.first, of.second, old.first, old.second);
        };
        gesture.hoverEnd = (e) {
          _lastHover = Pair(Offset.zero, Offset.zero);
          onHoverEnd();
        };
      } else {
        gesture.hoverStart = null;
        gesture.hoverMove = null;
        gesture.hoverEnd = null;
      }
    }

    if (type == GestureType.longPress) {
      if (enable) {
        gesture.longPressStart = (e) {
          _lastLongPress = toLocal(e.globalPosition);
          onLongPressStart(_lastLongPress, e.globalPosition);
        };
        gesture.longPressMove = (e) {
          var offset = toLocal(e.globalPosition);
          var dx = offset.dx - _lastLongPress.dx;
          var dy = offset.dy - _lastLongPress.dy;
          _lastLongPress = offset;
          if (!canFreeLongPress) {
            if (_lpDirection == null) {
              if (dx.abs() <= 1e-6) {
                _lpDirection = Direction.vertical;
              } else if (dy.abs() <= 1e-6) {
                _lpDirection = Direction.horizontal;
              } else {
                var angle = atan(dy.abs() / dx.abs());
                if (angle.isNaN) {
                  _lpDirection = Direction.horizontal;
                } else {
                  _lpDirection = angle.abs() < 30 * pi / 180 ? Direction.horizontal : Direction.vertical;
                }
              }
            }
            if (_lpDirection == Direction.horizontal) {
              dy = 0;
            } else {
              dx = 0;
            }
          }
          onLongPressMove(offset, e.globalPosition, Offset(dx, dy));
        };
        gesture.longPressEnd = () {
          _lpDirection = null;
          _lastLongPress = Offset.zero;
          onLongPressEnd();
        };
      } else {
        gesture.longPressStart = null;
        gesture.longPressMove = null;
        gesture.longPressEnd = null;
      }
    }

    if (type == GestureType.drag) {
      if (enable) {
        gesture.dragStart = (e) {
          var offset = toLocal(e.globalPosition);
          _lastDrag = offset;
          onDragStart(offset, e.globalPosition);
        };
        gesture.dragMove = (e) {
          var offset = toLocal(e.globalPosition);
          var dx = offset.dx - _lastDrag.dx;
          var dy = offset.dy - _lastDrag.dy;
          _lastDrag = offset;
          if (!canFreeDrag) {
            if (_dragDirection == null) {
              if (dx.abs() <= 1e-6) {
                _dragDirection = Direction.vertical;
              } else if (dy.abs() <= 1e-6) {
                _dragDirection = Direction.horizontal;
              } else {
                var angle = atan(dy.abs() / dx.abs());
                if (angle.isNaN) {
                  _dragDirection = Direction.horizontal;
                } else {
                  _dragDirection = angle.abs() < 30 * pi / 180 ? Direction.horizontal : Direction.vertical;
                }
              }
            }
            if (_dragDirection == Direction.horizontal) {
              dy = 0;
            } else {
              dx = 0;
            }
          }
          onDragMove(offset, e.globalPosition, Offset(dx, dy));
        };
        gesture.dragEnd = () {
          _dragDirection = null;
          _lastDrag = Offset.zero;
          onDragEnd();
        };
      } else {
        gesture.dragStart = null;
        gesture.dragMove = null;
        gesture.dragEnd = null;
      }
    }

    if (type == GestureType.scale) {
      if (enable) {
        gesture.scaleStart = (e) {
          onScaleStart(toLocal(e.globalPosition), e.globalPosition);
        };
        gesture.scaleUpdate = (e) {
          onScaleUpdate(toLocal(e.focalPoint), e.focalPoint, e.rotation, e.scale, false);
        };
        gesture.scaleEnd = () {
          onScaleEnd();
        };
      } else {
        gesture.scaleStart = null;
        gesture.scaleUpdate = null;
        gesture.scaleEnd = null;
      }
    }
  }

  ///是否自由长按
  ///当为false时 拖拽将固定为只能在水平或者竖直方向
  bool get canFreeLongPress => true;

  ///是否自由拖拽
  ///当为false时 拖拽将固定为只能在水平或者竖直方向
  bool get canFreeDrag => true;

  void onClick(Offset local, Offset global) {}

  void onDoubleClick(Offset local, Offset global) {}

  void onHoverStart(Offset local, Offset global) {}

  void onHoverMove(Offset local, Offset global, Offset lastLocal, Offset lastGlobal) {}

  void onHoverEnd() {}

  void onLongPressStart(Offset local, Offset global) {}

  void onLongPressMove(Offset local, Offset global, Offset diff) {}

  void onLongPressEnd() {}

  void onDragStart(Offset local, Offset global) {}

  void onDragMove(Offset local, Offset global, Offset diff) {
    scrollOff(diff.dx, diff.dy);
  }

  void onDragEnd() {}

  void onScaleStart(Offset local, Offset global) {}

  void onScaleUpdate(Offset local, Offset global, double rotation, double scale, bool doubleClick) {}

  void onScaleEnd() {}
}
