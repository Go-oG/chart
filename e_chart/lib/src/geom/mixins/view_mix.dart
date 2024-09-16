import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于帮助实现数据映射视图
mixin ViewEventMix on ChartView {
  void sendClickEvent(DataNode node, Offset local, Offset global) {
    if (context.hasEventListener(EventType.click)) {
      var event = ClickEvent(local, global, buildEvent(node));
      context.dispatchEvent(event);
    }
  }

  void sendHoverStartEvent(DataNode node, Offset local, Offset global) {
    if (!context.hasEventListener(EventType.hoverStart)) {
      return;
    }
    context.dispatchEvent(HoverStartEvent(local, global, buildEvent(node)));
  }

  HoverUpdateEvent? _lastHoverEvent;

  void sendHoverEvent(DataNode node, Offset local, Offset global) {
    if (context.hasEventListener(EventType.hoverUpdate)) {
      var lastEvent = _lastHoverEvent;
      HoverUpdateEvent? event;
      if (lastEvent != null) {
        var old = lastEvent.event;
        if (old.dataNode == node) {
          event = lastEvent;
          event.localOffset = local;
          event.globalOffset = global;
        }
      }

      event ??= HoverUpdateEvent(local, global, buildEvent(node));
      _lastHoverEvent = event;
      context.dispatchEvent(event);
    }
  }

  void sendHoverEndEvent(DataNode node, Offset local, Offset global,
      [ComponentType componentType = ComponentType.geom]) {
    if (!context.hasEventListener(EventType.hoverEnd)) {
      return;
    }
    context.dispatchEvent(HoverEndEvent(buildEvent(node, componentType), local, global));
  }

  EventInfo buildEvent(DataNode data, [ComponentType componentType = ComponentType.geom]) {
    return EventInfo(componentType, data, data.data);
  }

  /// 事件处理相关
  ViewTranslationEvent? _translationEvent;

  void sendTranslationEvent(Geom geom) {
    if (!context.hasEventListener(EventType.viewTranslation)) {
      return;
    }
    _translationEvent ??= ViewTranslationEvent(geom, id, translationX, translationY);
    _translationEvent!.translationX = translationX;
    _translationEvent!.translationY = translationY;
    context.dispatchEvent(_translationEvent!);
  }

  ViewScaleEvent? _scaleEvent;

  void sendScaleEvent(Geom geom, double zoom, double originX, double originY) {
    if (!context.hasEventListener(EventType.viewScale)) {
      return;
    }
    _scaleEvent ??= ViewScaleEvent(geom, id, 1, 0, 0);
    _scaleEvent!.zoom = zoom;
    _scaleEvent!.originY = originY;
    _scaleEvent!.originX = originX;
    context.dispatchEvent(_scaleEvent!);
  }
}
