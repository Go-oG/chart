import 'package:flutter/gestures.dart';

import '../../model/helper/pool.dart';

class MotionEvent {
  const MotionEvent();
}

final class TapEvent extends MotionEvent {
  static final _eventPool = Pool<TapEvent>(() => TapEvent._(Offset.zero, Offset.zero, 0), (obj, fields) {
    obj.localPos = fields["localPos"];
    obj.position = fields["position"];
    obj.pointer = fields["pointer"];
  }, 6);

  static TapEvent of(Offset localPos, Offset position, int pointer) {
    return _eventPool.get({"localPos": localPos, "position": position, "pointer": pointer});
  }

  late int pointer;
  late Offset localPos;
  late Offset position;

  TapEvent._(this.localPos, this.position, this.pointer);

  static from(PointerEvent event) {
    return TapEvent.of(event.localPosition, event.position, event.pointer);
  }

  Offset get globalPosition => localPos;

  void recycle() {
    _eventPool.recycle(this);
  }
}

final class ScaleEvent extends MotionEvent {
  static final _eventPool = Pool<ScaleEvent>(() => ScaleEvent._(Offset.zero, 0, 0), (obj, fields) {
    obj.focalPoint = fields["focalPoint"];
    obj.scale = fields["scale"];
    obj.rotation = fields["rotation"];
  }, 6);

  static ScaleEvent of(Offset focalPoint, double scale, double rotation) {
    return _eventPool.get({"focalPoint": focalPoint, "scale": scale, "rotation": rotation});
  }

  late Offset focalPoint;
  late double scale;
  late double rotation;

  ScaleEvent._(this.focalPoint, this.scale, this.rotation);

  void recycle() {
    _eventPool.recycle(this);
  }
}

final class LongPressMoveEvent extends MotionEvent {
  final Offset globalPosition;
  final Offset localOffsetFromOrigin;
  final Offset offsetFromOrigin;

  const LongPressMoveEvent(
    this.globalPosition,
    this.localOffsetFromOrigin,
    this.offsetFromOrigin,
  );
}

final class MoveEvent extends MotionEvent {
  static final _eventPool = Pool<MoveEvent>(() => MoveEvent._(Offset.zero, Offset.zero, 0), (obj, fields) {
    obj.localPos = fields["localPos"];
    obj.position = fields["position"];
    obj.pointer = fields["pointer"];
    obj.delta = fields["delta"] ?? Offset.zero;
    obj.localDelta = fields["localDelta"] ?? Offset.zero;
  }, 6);

  static MoveEvent of(
    Offset localPos,
    Offset position,
    int pointer, {
    Offset localDelta = Offset.zero,
    Offset delta = Offset.zero,
  }) {
    return _eventPool.get(
        {"localPos": localPos, "position": position, "pointer": pointer, "localDelta": localDelta, "delta": delta});
  }

  late int pointer;
  late Offset localPos;
  late Offset position;
  late Offset localDelta;
  late Offset delta;

  MoveEvent._(
    this.localPos,
    this.position,
    this.pointer, {
    this.localDelta = Offset.zero,
    this.delta = Offset.zero,
  });

  void recycle() {
    _eventPool.recycle(this);
  }

  Offset get globalPosition => localPos;
}

final class ScrollEvent extends MotionEvent {
  static final _eventPool =
      Pool<ScrollEvent>(() => ScrollEvent._(0, Offset.zero, Offset.zero, Offset.zero), (obj, fields) {
    obj.pointer = fields["pointer"];
    obj.localPos = fields["localPos"];
    obj.position = fields["position"];
    obj.scrollDelta = fields["scrollDelta"];
  }, 6);

  static ScrollEvent of(int pointer, Offset localPos, Offset position, Offset scrollDelta) {
    return _eventPool.get({"pointer": pointer, "localPos": localPos, "position": position, "scrollDelta": scrollDelta});
  }

  late int pointer;
  late Offset localPos;
  late Offset position;
  late Offset scrollDelta;

  ScrollEvent._(this.pointer, this.localPos, this.position, this.scrollDelta);

  void recycle() {
    _eventPool.recycle(this);
  }
}
