import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

///用于辅助布局相关的抽象类，通常和GeomView 配合使用
///其包含了Chart事件分发、处理以及手势等相关处理
mixin ViewHelper on AnimateGeomView {
  ///标识是否在运行动画

  ///控制在动画期间是否允许手势
  bool allowGestureInAnimation = false;

  void stopLayout() {}

  @override
  void dispose() {
    unsubscribeLegendEvent();
    unsubscribeBrushEvent();
    unsubscribeAxisChangeEvent();
    super.dispose();
  }

  Offset viewOffset(SNumber x, SNumber y) {
    return Offset(x.convert(width), y.convert(height));
  }

  void onGeomDataUpdate() {
    onLayout(false, left, top, right, bottom);
    notifyLayoutUpdate();
  }

  ///========通知布局节点刷新=======
  void notifyLayoutUpdate() {
    repaint();
  }

  ///获取裁剪路径
  Rect getClipRect(Direction direction, [double animationPercent = 1]) {
    if (animationPercent > 1) {
      animationPercent = 1;
    }
    if (animationPercent < 0) {
      animationPercent = 0;
    }
    if (direction == Direction.horizontal) {
      return Rect.fromLTWH(scrollX, scrollY, width * animationPercent, height);
    } else {
      return Rect.fromLTWH(scrollX, scrollY, width, height * animationPercent);
    }
  }

  ///获取动画运行配置(可以为空)
  @override
  AnimateOption? getAnimateOption(LayoutType type, [int count = -1]) {
    var attr = geom.animation ?? context.option.animate;
    if (type == LayoutType.none || attr == null) {
      return null;
    }
    if (count > 0 && count > attr.threshold && attr.threshold > 0) {
      return null;
    }
    if (type == LayoutType.layout) {
      if (attr.duration.inMilliseconds <= 0) {
        return null;
      }
      return attr;
    }
    if (type == LayoutType.update) {
      if (attr.updateDuration.inMilliseconds <= 0) {
        return null;
      }
      return attr;
    }
    return null;
  }

  void onSyncScroll(CoordType type, double scrollX, double scrollY) {}

  ///注册Brush组件 Event监听器

  void subscribeBrushEvent() {
    context.addEventCall(EventType.brush, onBrushEvent as VoidFun1<ChartEvent>);
  }

  void unsubscribeBrushEvent() {
    context.removeEventCall(onBrushEvent as VoidFun1);
  }

  void onBrushEvent(covariant BrushEvent event) {}

  /// 注册Legend组件事件
  void subscribeLegendEvent() {
    context.addEventCall(EventType.legendScroll, onLegendScroll as VoidFun1<ChartEvent>?);
    context.addEventCall(EventType.legend, onLegendEvent as VoidFun1<ChartEvent>?);
  }

  void onLegendEvent(covariant LegendEvent event) {}

  void onLegendScroll(covariant LegendScrollEvent event) {}

  void unsubscribeLegendEvent() {
    context.removeEventCall(onLegendEvent as VoidFun1<ChartEvent>?);
    context.removeEventCall(onLegendScroll as VoidFun1<ChartEvent>?);
  }

  //========Legend 结束================

  void onAxisScroll(AxisScrollEvent event) {}

  VoidFun1<ChartEvent>? _axisChangeListener;

  void subscribeAxisChangeEvent() {
    context.removeEventCall(_axisChangeListener);
    _axisChangeListener = (event) {
      if (event is AxisChangeEvent) {
        onAxisChange(event);
        return;
      }
    };
    context.addEventCall(EventType.axisChange, _axisChangeListener);
  }

  void unsubscribeAxisChangeEvent() {
    context.removeEventCall(_axisChangeListener);
    _axisChangeListener = null;
  }

  void onAxisChange(AxisChangeEvent event) {}
}
