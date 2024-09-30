import 'dart:async';
import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///实现二维坐标系
class GridCoordImpl extends GridCoord {
  final Map<XAxis, XAxisImpl> xMap = {};
  final Map<YAxis, YAxisImpl> yMap = {};

  GridCoordImpl(super.context, super.props) {
    layoutParams = LayoutParams.matchAll();
    each(option.xAxisList, (ele, p1) {
      var view = XAxisImpl(Direction.horizontal, context, ele, this, axisIndex: p1);
      addView(view);
      xMap[ele] = view;
    });
    each(option.yAxisList, (axis, p1) {
      var view = YAxisImpl(Direction.vertical, context, axis, this, axisIndex: p1);
      yMap[axis] = view;
      addView(view);
    });
  }

  @override
  void onDispose() {
    xMap.forEach((key, value) {
      value.dispose();
    });
    yMap.forEach((key, value) {
      value.dispose();
    });
    xMap.clear();
    yMap.clear();
    super.onDispose();
  }

  @override
  Future<void> onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) async {
    var parentWidth = widthSpec.size;
    var parentHeight = heightSpec.size;

    ///赋值MaxStr
    xMap.forEach((key, value) {
      value.attrs.maxStr = getMaxStr(value.direction, value.axisIndex);
    });
    yMap.forEach((key, value) {
      value.attrs.maxStr = getMaxStr(value.direction, value.axisIndex);
    });

    var lp = layoutParams;
    double pw = lp.width.convert(parentWidth - layoutParams.hPadding);
    double ph = lp.height.convert(parentHeight - layoutParams.vPadding);

    var ws = MeasureSpec.exactly(pw);
    var hs = MeasureSpec.exactly(ph);
    for (var child in children) {
      child.measure(ws, hs);
    }
    setMeasuredDimension(parentWidth, parentHeight);
  }

  @override
  Future<void> onLayout(bool changed, double left, double top, double right, double bottom) async {
    left = layoutParams.leftPadding;
    top = layoutParams.topPadding;
    bottom = height - layoutParams.bottomPadding;
    right = width - layoutParams.rightPadding;

    ///计算所有X轴在竖直方向上的占用的高度
    List<XAxisImpl> topList = [];
    List<XAxisImpl> bottomList = [];
    for (var ele in option.xAxisList) {
      if (ele.position == Align2.start) {
        topList.add(xMap[ele]!);
      } else {
        bottomList.add(xMap[ele]!);
      }
    }
    top += computeAxisSize(topList, false);
    bottom -= computeAxisSize(bottomList, false);

    ///计算所有Y轴在横向方向上的占用的宽度
    List<YAxisImpl> leftList = [];
    List<YAxisImpl> rightList = [];
    for (var ele in option.yAxisList) {
      var axis = yMap[ele]!;
      if (ele.position == Align2.end) {
        rightList.add(axis);
      } else {
        leftList.add(axis);
      }
    }
    left += computeAxisSize(leftList, true);
    right -= computeAxisSize(rightList, true);

    contentBox = Rect.fromLTRB(left, top, right, bottom);
    List<CoordChild> childList = getCoordChildList();

    ///布局X轴
    await layoutXAxis(childList, contentBox);

    ///布局Y轴
    await layoutYAxis(childList, contentBox);

    viewPort.setAreaAndValue(contentBox);

    var virtualWidth = viewPort.virtualWidth;
    var virtualHeight = viewPort.virtualHeight;

    // xMap.forEach((key, value) {
    //   viewPort.contentWidth = value.attrs.distance;
    // });
    //
    // yMap.forEach((key, value) {
    //   if (value.attrs.distance > viewPort.contentHeight) {
    //     viewPort.contentHeight = value.attrs.distance;
    //   }
    // });

    ///修正由于坐标系线条宽度导致的遮挡
    top = topList.isEmpty ? 0 : topList.first.axis.axisLine.width / 2;
    bottom = bottomList.isEmpty ? 0 : bottomList.first.axis.axisLine.width / 2;
    left = leftList.isEmpty ? 0 : leftList.first.axis.axisLine.width / 2;
    right = rightList.isEmpty ? 0 : rightList.first.axis.axisLine.width / 2;
    double ll = contentBox.left + left;
    double tt = contentBox.top + top;

    for (var view in children) {
      if (view is AxisView) {
        continue;
      }
      double rr, bb;
      if (view.layoutParams.width.isMatch) {
        rr = contentBox.right - right;
      } else {
        rr = ll + view.width;
      }
      if (view.layoutParams.height.isMatch) {
        bb = contentBox.bottom - bottom;
      } else {
        bb = tt + view.height;
      }
      await view.layout(ll, tt, rr, bb);
    }
  }

  ///布局X轴
  FutureOr<void> layoutXAxis(List<CoordChild> childList, Rect contentBox) async {
    List<XAxisImpl> topList = [];
    List<XAxisImpl> bottomList = [];

    bool needAlignTick = false;
    for (var ele in option.xAxisList) {
      var axis = xMap[ele]!;
      if (ele.position == Align2.end) {
        bottomList.add(axis);
      } else {
        topList.add(axis);
      }
      if (axis.axis.alignTicks) {
        needAlignTick = true;
      }
    }

    int? splitCount;
    double topOffset = contentBox.top;
    each(topList, (axis, i) {
      var h = axis.measureHeight;
      var rect = Rect.fromLTWH(contentBox.left, topOffset - h, contentBox.width, h);
      var attrs = axis.attrs.copy() as GridAxisAttr;
      attrs.scrollX = viewPort.translationX;
      attrs.splitCount = splitCount;
      attrs.start = rect.bottomLeft;
      attrs.end = rect.bottomRight;
      attrs.rect = rect;
      topOffset -= (h + axis.axis.offset);
      axis.layout(rect.left, rect.top, rect.right, rect.bottom);
    });

    double bottomOffset = contentBox.bottom;
    for (var axis in bottomList) {
      var h = axis.measureHeight;
      var rect = Rect.fromLTWH(contentBox.left, bottomOffset, contentBox.width, h);
      var attrs = axis.attrs.copy() as GridAxisAttr;
      attrs.scaleRatio = scaleX;
      attrs.scrollY = viewPort.translationY;
      attrs.scrollX = viewPort.translationX;
      attrs.splitCount = splitCount;
      attrs.start = rect.topLeft;
      attrs.end = rect.topRight;
      attrs.rect = rect;

      bottomOffset += (h + axis.axis.offset);
      await axis.layout(rect.left, rect.top, rect.right, rect.bottom);
    }
  }

  FutureOr<void> layoutYAxis(List<CoordChild> childList, Rect contentBox) async {
    List<YAxisImpl> leftList = [];
    List<YAxisImpl> rightList = [];

    bool needAlignTick = false;
    for (var ele in option.yAxisList) {
      var axis = yMap[ele]!;
      if (ele.position == Align2.end) {
        rightList.add(axis);
      } else {
        leftList.add(axis);
      }
      if (axis.axis.alignTicks) {
        needAlignTick = true;
      }
    }

    int? splitCount;
    double rightOffset = contentBox.left;
    each(leftList, (value, i) {
      if (i != 0) {
        rightOffset -= value.axis.offset;
      }
      double w = value.measureWidth;
      var rect = Rect.fromLTRB(rightOffset - w, contentBox.top, rightOffset, contentBox.bottom);

      var attrs = value.attrs.copy() as GridAxisAttr;
      attrs.scaleRatio = scaleY;
      attrs.scrollY = viewPort.translationY;
      attrs.scrollX = viewPort.translationX;
      attrs.splitCount = splitCount;
      attrs.start = rect.bottomRight;
      attrs.end = rect.topRight;
      attrs.rect = rect;
      value.attrs = attrs;

      rightOffset -= w;
      value.layout(rect.left, rect.top, rect.right, rect.bottom);

      if (needAlignTick && i == 0) {
        splitCount = value.axisScale.tickCount - 1;
      }
    });
    double leftOffset = contentBox.right;

    int i = 0;
    for (var value in rightList) {
      if (i != 0) {
        leftOffset += value.axis.offset;
      }
      double w = value.measureWidth;
      var rect = Rect.fromLTWH(leftOffset, contentBox.top, w, contentBox.height);
      var attrs = value.attrs.copy() as GridAxisAttr;
      attrs.scaleRatio = scaleY;
      attrs.scrollY = viewPort.translationY;
      attrs.scrollX = viewPort.translationX;
      attrs.splitCount = splitCount;
      attrs.start = rect.bottomLeft;
      attrs.end = rect.topLeft;
      attrs.rect = rect;
      leftOffset += w;
      value.attrs = attrs;
      await value.layout(rect.left, rect.top, rect.right, rect.bottom);
      if (needAlignTick && splitCount == null && i == 0) {
        splitCount = value.axisScale.tickCount - 1;
      }
      i++;
    }
  }

  @override
  void onChildDataSetChange(bool layoutChild) {
    for (var view in children) {
      view.forceLayout();
    }
    onLayout(false, left, top, right, bottom);
  }

  @override
  void onRelayoutAxisByChild(bool xAxis, bool notifyInvalidate) {
    if (xAxis) {
      layoutXAxis(getCoordChildList(), contentBox);
    } else {
      layoutYAxis(getCoordChildList(), contentBox);
    }
    context.dispatchEvent(AxisChangeEvent(
        this,
        xAxis ? xMap.values.toList(growable: false) : yMap.values.toList(growable: false),
        xAxis ? Direction.horizontal : Direction.vertical));
    if (notifyInvalidate) {
      repaint();
    }
  }

  @override
  void onDraw(Canvas2 canvas) {
    xMap.forEach((key, value) {
      value.draw(canvas);
    });
    yMap.forEach((key, value) {
      value.draw(canvas);
    });
  }

  void onDrawEnd(Canvas2 canvas) {
    var offset = _axisPointerOffset;
    if (offset == null) {
      return;
    }
    xMap.forEach((key, value) {
      value.onDrawAxisPointer(canvas, mPaint, offset);
    });
    yMap.forEach((key, value) {
      value.onDrawAxisPointer(canvas, mPaint, offset);
    });
  }

  @override
  void onDragMove(Offset local, Offset global, Offset diff) {
    if (!contentBox.contains(local)) {
      return;
    }
    if (diff.dx != 0 && diff.dy != 0) {
      throw ChartError("只支持在一个方向滚动");
    }

    var oldTx = viewPort.translationX;
    var oldTy = viewPort.translationY;
    viewPort.translation(diff.dx, diff.dy);

    if (!numEqual(oldTx, viewPort.translationX)) {
      context.dispatchEvent(AxisScrollEvent(this, xMap.values.toList(growable: false), diff.dx, Direction.horizontal));
    }
    if (!numEqual(oldTy, viewPort.translationY)) {
      context.dispatchEvent(AxisScrollEvent(this, yMap.values.toList(growable: false), diff.dy, Direction.horizontal));
    }
  }

  @override
  void onScaleUpdate(Offset local, Offset global, double rotation, double scale, bool doubleClick) {
    if (!contentBox.contains(local)) {
      return;
    }
    var sx = scaleX + scale * m.cos(rotation);
    if (sx < 0.001) {
      sx = 0.001;
    }
    if (sx > 100) {
      sx = 100;
    }
    bool hasChange = false;
    if (sx != scaleX) {
      hasChange = true;
      scaleX = sx;
      xMap.forEach((key, value) {
        value.attrs.scaleRatio = scaleX;
        var rect = value.attrs.rect;
        value.layout(rect.left, rect.top, rect.right, rect.bottom);
      });
    }
    var sy = scaleY + scale * m.sin(rotation);
    if (sy < 0.001) {
      sy = 0.001;
    }
    if (sy > 100) {
      sy = 100;
    }
    if (sy != scaleY) {
      hasChange = true;
      scaleY = sy;
      yMap.forEach((key, value) {
        value.attrs.scaleRatio = sy;
        var rect = value.attrs.rect;
        value.layout(rect.left, rect.top, rect.right, rect.bottom);
      });
    }
    if (hasChange) {
      requestLayout();
    }
  }

  Offset? _axisPointerOffset;

  @override
  void onHoverStart(Offset local, Offset global) {
    super.onHoverStart(local, global);
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = local.translate(viewPort.translationX, viewPort.translationY);
      repaint();
    }
  }

  @override
  void onHoverMove(Offset local, Offset global, Offset lastLocal, Offset lastGlobal) {
    super.onHoverMove(local, global, lastLocal, lastGlobal);
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = local.translate(viewPort.translationX, viewPort.translationY);
      repaint();
    }
  }

  @override
  void onHoverEnd() {
    super.onHoverEnd();
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = null;
      repaint();
    }
  }

  @override
  void onClick(Offset local, Offset global) {
    if (needInvalidateAxisPointer(true)) {
      _axisPointerOffset = local.translate(viewPort.translationX, viewPort.translationY);
      if (!contentBox.contains(local)) {
        _axisPointerOffset = null;
      }
      repaint();
    }
  }

  bool needInvalidateAxisPointer(bool click) {
    for (var entry in xMap.entries) {
      var axisPointer = entry.value.axis.axisPointer;
      if (axisPointer == null || !axisPointer.show) {
        continue;
      }
      if (axisPointer.triggerOn == TriggerOn.none) {
        continue;
      }
      if (axisPointer.triggerOn == TriggerOn.moveAndClick) {
        return true;
      }
      if (click && axisPointer.triggerOn == TriggerOn.click) {
        return true;
      }
      if (!click && axisPointer.triggerOn == TriggerOn.mouseMove) {
        return true;
      }
    }
    for (var entry in yMap.entries) {
      var axisPointer = entry.value.axis.axisPointer;
      if (axisPointer == null || !axisPointer.show) {
        continue;
      }
      if (axisPointer.triggerOn == TriggerOn.none) {
        continue;
      }
      if (axisPointer.triggerOn == TriggerOn.moveAndClick) {
        return true;
      }
      if (click && axisPointer.triggerOn == TriggerOn.click) {
        return true;
      }
      if (!click && axisPointer.triggerOn == TriggerOn.mouseMove) {
        return true;
      }
    }
    return false;
  }

  double computeAxisSize(List<BaseGridAxisImpl> axisList, bool useWidth) {
    double size = 0;
    each(axisList, (axis, i) {
      size += useWidth ? axis.measureWidth : axis.measureHeight;
      if (i != 0) {
        size += axis.axis.offset;
      }
    });
    return size;
  }

  @override
  bool get canFreeDrag => false;

  @override
  int get dimCount => 2;

  @override
  int getDimAxisCount(Dim dim) {
    if (dim == Dim.x) {
      return xMap.length;
    }
    return yMap.length;
  }

  @override
  double convert(AxisDim dim, double ratio) {
    var axisMap = dim.isCol ? xMap : yMap;
    var axisCfg = dim.isCol ? option.xAxisList : option.yAxisList;
    var axis = axisMap[axisCfg[dim.index]]!;
    return axis.axisScale.convertRatio(ratio);
  }

  @override
  double convert2(AxisDim dim, dynamic value) {
    var axisMap = dim.isCol ? xMap : yMap;
    var axisCfg = dim.isCol ? option.xAxisList : option.yAxisList;
    var axis = axisMap[axisCfg[dim.index]]!;
    return axis.axisScale.convert(value);
  }

  @override
  RangeInfo getAxisViewportRange(AxisDim dim) {
    GridAxis axis;
    XAxisImpl impl;
    if (dim.dim.isX) {
      axis = option.xAxisList[dim.index];
      impl = xMap[axis]!;
    } else {
      axis = option.yAxisList[dim.index];
      impl = yMap[axis]!;
    }
    return impl.getViewportDataRange();
  }
}

abstract class GridCoord extends CoordView<Grid> {
  GridCoord(super.context, super.props);

  ///=====下面的方法由子视图回调
  ///当子视图的数据集发生改变时需要重新布局确定坐标系
  void onChildDataSetChange(bool layoutChild);

  ///当子视图需要实现动态坐标轴时回调该方法
  void onRelayoutAxisByChild(bool xAxis, bool notifyInvalidate);

  DynamicText getMaxStr(Direction direction, int axisIndex) {
    DynamicText maxStr = DynamicText.empty;
    Size size = Size.zero;
    bool isXAxis = direction == Direction.horizontal;
    var dim = GridAxisDim(isXAxis, axisIndex);
    for (var ele in getCoordChildList()) {
      var text = ele.getAxisMaxText(coordType, dim);
      if ((maxStr.isString || maxStr.isTextSpan) && (text.isString || text.isTextSpan)) {
        if (text.length > maxStr.length) {
          maxStr = text;
        }
      } else {
        if (size == Size.zero) {
          size = maxStr.getTextSize();
        }
        Size size2 = text.getTextSize();
        if ((size2.height > size.height && isXAxis) || (!isXAxis && size2.width > size.width)) {
          maxStr = text;
          size = size2;
        }
      }
    }
    return maxStr;
  }

  double convert2(AxisDim dim, dynamic value);

  RangeInfo getAxisViewportRange(AxisDim dim);
}
