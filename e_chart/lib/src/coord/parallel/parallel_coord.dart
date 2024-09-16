import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///平行坐标系
class ParallelCoordImpl extends ParallelCoord {
  Map<ParallelAxis, ParallelAxisView> _axisMap = {};

  ParallelCoordImpl(super.context, super.props) {
    var direction = option.direction == Direction.vertical ? Direction.horizontal : Direction.vertical;

    each(option.axisList, (ele, i) {
      var view = ParallelAxisView(direction, context, ele, this, axisIndex: i);
      _axisMap[ele] = view;
      addView(view);
    });
  }

  @override
  void onDispose() {
    super.onDispose();
    _axisMap = {};
  }

  @override
  bool get enableScale => false;

  ///找到离点击点最近的轴
  ParallelAxisView? findMinDistanceAxis(Offset offset) {
    ParallelAxisView? node;
    num distance = 0;
    for (var ele in _axisMap.values) {
      if (node == null) {
        node = ele;
        if (option.direction == Direction.horizontal) {
          distance = (node.attrs.rect.left - offset.dx).abs();
        } else {
          distance = (node.attrs.rect.top - offset.dy).abs();
        }
      } else {
        double tmp;
        if (option.direction == Direction.horizontal) {
          tmp = (ele.attrs.rect.left - offset.dx).abs();
        } else {
          tmp = (ele.attrs.rect.top - offset.dy).abs();
        }
        if (tmp < distance) {
          distance = tmp;
          node = ele;
        }
      }
    }
    return node;
  }

  bool isFirstAxis(AxisView node) {
    bool hasCheck = false;
    for (var axis in option.axisList) {
      var node2 = _axisMap[axis]!;
      if (node == node2) {
        return !hasCheck;
      }
    }
    return false;
  }

  bool isLastAxis(AxisView node) {
    bool hasCheck = false;
    for (int i = option.axisList.length - 1; i >= 0; i--) {
      var node2 = _axisMap[option.axisList[i]]!;

      if (node == node2) {
        return !hasCheck;
      }
    }
    return false;
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    final double leftOffset = layoutParams.leftPadding;
    final double topOffset = layoutParams.topPadding;
    final double rightOffset = layoutParams.rightPadding;
    final double bottomOffset = layoutParams.bottomPadding;

    double w = width - leftOffset - rightOffset;
    double h = height - topOffset - bottomOffset;
    contentBox = Rect.fromLTWH(leftOffset, topOffset, w, h);

    bool horizontal = option.direction == Direction.horizontal;
    double size = (horizontal ? w : h);

    int expandCount = 0;
    int unExpandCount = 0;
    _axisMap.forEach((key, value) {
      if (value.expand) {
        expandCount += 1;
      } else {
        unExpandCount += 1;
      }
    });

    num unExpandAllSize = option.expandWidth * unExpandCount;
    num remainSize = size - unExpandAllSize;
    double interval;
    if (expandCount > 0) {
      interval = remainSize / expandCount;
    } else {
      interval = 0;
    }
    double offsetP = horizontal ? leftOffset : topOffset;

    ///计算在不同布局方向上前后占用的最大高度或者宽度
    List<Size> textSize = measureAxisNameTextMaxSize(_axisMap.keys, option.direction, max(interval, option.expandWidth));

    for (var axis in option.axisList) {
      var axisImpl = _axisMap[axis]!;
      double tmpLeft;
      double tmpTop;
      double tmpRight;
      double tmpBottom;
      if (horizontal) {
        tmpLeft = offsetP;
        tmpRight = tmpLeft + (axisImpl.expand ? interval : option.expandWidth);
        tmpTop = topOffset;
        tmpBottom = h;
        offsetP += (tmpRight - tmpLeft);
      } else {
        tmpLeft = leftOffset;
        tmpTop = offsetP;
        tmpRight = width - rightOffset;
        tmpBottom = tmpTop + (axisImpl.expand ? interval : option.expandWidth);
        offsetP += (axisImpl.expand ? interval : option.expandWidth);
      }

      ///处理轴内部
      Rect rect = Rect.fromLTRB(tmpLeft, tmpTop, tmpRight, tmpBottom);
      Offset start, end;
      if (option.direction == Direction.horizontal) {
        start = rect.bottomLeft.translate(0, -textSize[1].height);
        end = rect.topLeft.translate(0, textSize[0].height);
      } else {
        start = rect.topLeft.translate(textSize[0].width, 0);
        end = rect.topRight.translate(-textSize[1].width, 0);
      }

      var attrs = axisImpl.attrs.copy();
      attrs.start = start;
      attrs.end = end;
      attrs.textStartSize = textSize[0];
      attrs.textEndSize = textSize[1];
      attrs.rect = rect;
      axisImpl.attrs = attrs;
      axisImpl.layout(rect.left, 0, rect.right, height);
    }

    for (var ele in children) {
      if (ele is! AxisView) {
        ele.layout(0, 0, width, height);
      }
    }
  }

  @override
  void onDraw(Canvas2 canvas) {
    for (var ele in _axisMap.entries) {
      ele.value.draw(canvas);
    }
  }

  ///找到当前点击的
  AxisView? findClickAxis(Offset offset) {
    AxisView? node;
    for (var ele in _axisMap.entries) {
      List<Offset> ol;
      if (option.direction == Direction.horizontal) {
        ol = [ele.value.attrs.rect.topLeft, ele.value.attrs.rect.bottomLeft];
      } else {
        ol = [ele.value.attrs.rect.topLeft, ele.value.attrs.rect.topRight];
      }
      if (offset.inLine(ol[0], ol[1])) {
        node = ele.value;
        break;
      }
    }
    return node;
  }

  @override
  int get dimCount => option.axisList.length;

  @override
  int getDimAxisCount(Dim dim) => 1;

  @override
  double convert(AxisDim dim, double ratio) {
    var axis = _axisMap[option.axisList[dim.index]]!;
    if (dim.isCol) {
      if (direction == Direction.horizontal) {
        return axis.attrs.rect.center.dx;
      }
      return axis.axisScale.convertRatio(ratio);
    } else {
      if (direction == Direction.vertical) {
        return axis.axisScale.convertRatio(ratio);
      }
      return axis.attrs.rect.center.dy;
    }
  }

  @override
  double convert2(AxisDim dim, dynamic value) {
    var axis = _axisMap[option.axisList[dim.index]]!;
    if (dim.isCol) {
      if (direction == Direction.horizontal) {
        return axis.attrs.rect.center.dx;
      }
      return axis.axisScale.convert(value);
    } else {
      if (direction == Direction.vertical) {
        return axis.axisScale.convert(value);
      }
      return axis.attrs.rect.center.dy;
    }
  }
}

abstract class ParallelCoord extends CoordView<Parallel> {
  ParallelCoord(super.context, super.props);

  Direction get direction => option.direction;

  int getAxisCount() => option.axisList.length;

  double convert2(AxisDim dim, dynamic value);
}

class ParallelPosition {
  ///当为类目轴时其返回一个范围
  final List<Offset> points;

  ParallelPosition(this.points);

  Offset get center {
    if (points.length <= 1) {
      return points[0];
    }
    Offset p1 = points[0];
    Offset p2 = points[1];
    return Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
  }
}
