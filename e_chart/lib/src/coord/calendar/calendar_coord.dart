import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///日历坐标系视图
class CalendarCoordImpl extends CalendarCoord {
  Map<String, CalendarNode> _nodeMap = {};
  late DateTime _startTime = DateTime.now();
  late DateTime _endTime = DateTime.now();
  double cellWidth = 0;
  double cellHeight = 0;
  int _rowCount = 0;
  int _columnCount = 0;

  CalendarCoordImpl(super.context, super.props);

  @override
  Future<void>  onLayout(bool changed, double left, double top, double right, double bottom)async {
    Pair<DateTime, DateTime> pair = _adjustTime(option.range.first, option.range.second);
    _startTime = pair.first;
    _endTime = pair.second;
    int count = computeDayDiff(pair.first, pair.second);
    int tmpCount = count ~/ 7;
    if (count % 7 != 0) {
      tmpCount += 1;
    }
    _rowCount = option.direction.isVertical() ? tmpCount : 7;
    _columnCount = option.direction.isVertical() ? 7 : tmpCount;

    _nodeMap = {};
    List<DateTime> timeList = buildDateRange(pair.first, pair.second, true);
    int rowIndex = 0;
    int columnIndex = 0;

    for (var time in timeList) {
      _nodeMap[key(time)] = CalendarNode(time, rowIndex, columnIndex);
      if (option.direction == Direction.vertical) {
        columnIndex += 1;
        if (columnIndex >= 7) {
          columnIndex = 0;
          rowIndex += 1;
        }
      } else {
        rowIndex += 1;
        if (rowIndex >= 7) {
          columnIndex += 1;
          rowIndex = 0;
        }
      }
    }
    num vw = width;
    num vh = height;
    if (option.cellSize.isNotEmpty) {
      if (option.cellSize.length == 1) {
        num? size = option.cellSize[0];
        if (size != null) {
          vw = columnCount * size;
          vh = rowCount * size;
        }
      } else if (option.cellSize.length == 2) {
        num? w = option.cellSize[0];
        if (w != null) {
          vw = columnCount * w;
        }
        num? h = option.cellSize[1];
        if (h != null) {
          vh = rowCount * h;
        }
      }
    }

    cellWidth = vw / columnCount;
    cellHeight = vh / rowCount;
    _nodeMap.forEach((key, node) {
      double left = node.column * cellWidth;
      double top = node.row * cellHeight;
      node.rect = Rect.fromLTWH(left, top, cellWidth, cellHeight);
    });

    ///移除范围以外的数据
    _nodeMap.removeWhere((key, value) {
      if (value.date.isAfterDay(option.range.second) || value.date.isBeforeDay(option.range.first)) {
        return true;
      }
      return false;
    });

    // viewPort.width = width;
    // viewPort.height = height;
    // viewPort.contentWidth = cellWidth * columnCount;
    // viewPort.contentHeight = cellHeight * rowCount;

    super.onLayout(changed, left, top, right, bottom);
  }

  @override
  void onDraw(Canvas2 canvas) {
    if (option.gridLineStyle != null) {
      var style = option.gridLineStyle!;
      for (int i = 0; i < columnCount; i++) {
        Offset o1 = Offset(i * cellWidth, 0);
        Offset o2 = Offset(i * cellWidth, rowCount * cellHeight);
        style.drawPolygon(canvas, mPaint, [o1, o2]);
      }
      for (int i = 0; i < rowCount; i++) {
        Offset o1 = Offset(0, i * cellHeight);
        Offset o2 = Offset(columnCount * cellWidth, i * cellHeight);
        style.drawPolygon(canvas, mPaint, [o1, o2]);
      }
    }
    if (option.borderStyle != null) {
      var style = option.borderStyle!;
      DateTime first = option.range.first;
      int year = first.year;
      int month = first.month;
      int diff = first.diffMonth(option.range.second);
      for (int i = 0; i <= diff; i++) {
        DateTime t1 = DateTime(year, month, 1);
        DateTime t2 = DateTime(year, month, t1.maxDay());
        if (t2.isAfter(option.range.second)) {
          t2 = option.range.second;
        }
        style.drawPolygon(canvas, mPaint, getDateRangePolygon(t1, t2));
      }
    }
  }

  ///给定在制定月份的边缘
  ///相关数据必须在给定的范围以内
  @override
  List<Offset> getMonthPolygon(int year, int month) {
    DateTime? startDate = findMinDate(year, month);
    DateTime? endDate = findMaxDate(year, month);
    if (endDate == null || startDate == null) {
      throw ChartError('在给定的年月中无法找到对应数据');
    }
    return getDateRangePolygon(startDate, endDate);
  }

  @override
  List<Offset> getDateRangePolygon(DateTime start, DateTime end) {
    if (start.isAfter(end)) {
      var t = end;
      end = start;
      start = t;
    }
    CalendarNode? startNode = _nodeMap[key(start)];
    CalendarNode? endNode = _nodeMap[key(end)];
    if (startNode == null || endNode == null) {
      throw ChartError('给定的时间必须在时间范围以内');
    }
    List<Offset> offsetList = [];
    if (option.direction == Direction.vertical) {
      offsetList.add(startNode.rect.topLeft);
      offsetList.add(startNode.rect.topRight);
      if (startNode.column != columnCount - 1) {
        Offset offset = startNode.rect.topRight;
        offset = offset.translate(cellWidth * (columnCount - startNode.column - 1), 0);
        offsetList.add(offset);
      }
      offsetList.add(Offset(offsetList.last.dx, endNode.rect.topRight.dy));
      offsetList.add(endNode.rect.topLeft);
      offsetList.add(endNode.rect.bottomLeft);
      if (endNode.column != 0) {
        Offset offset = endNode.rect.bottomLeft;
        offset = offset.translate(-cellWidth * endNode.column, 0);
        offsetList.add(offset);
      }
      offsetList.add(Offset(offsetList.last.dx, startNode.rect.bottomLeft.dy));
    } else {
      offsetList.add(startNode.rect.topLeft);
      offsetList.add(startNode.rect.topRight);
      if (startNode.row != 0) {
        Offset offset = startNode.rect.topRight;
        offset = offset.translate(0, cellHeight * startNode.row);
        offsetList.add(offset);
      }
      offsetList.add(Offset(endNode.rect.topRight.dx, offsetList.last.dy));
      offsetList.add(endNode.rect.bottomRight);
      if (endNode.row != rowCount - 1) {
        offsetList.add(endNode.rect.bottomLeft);
        offsetList.add(Offset(offsetList.last.dx, endNode.rect.bottom + (columnCount - endNode.column) * cellHeight));
      }
      offsetList.add(Offset(startNode.rect.bottomLeft.dx, offsetList.last.dy));
    }
    return offsetList;
  }

  DateTime? findMinDate(int year, int month) {
    DateTime? start;
    _nodeMap.forEach((key, value) {
      if (value.date.year == year && value.date.month == month) {
        if (start == null) {
          start = value.date;
        } else {
          if (value.date.isBeforeDay(start!)) {
            start = value.date;
          }
        }
      }
    });
    return start;
  }

  DateTime? findMaxDate(int year, int month) {
    DateTime? end;
    _nodeMap.forEach((key, value) {
      if (value.date.year == year && value.date.month == month) {
        if (end == null) {
          end = value.date;
        } else {
          if (value.date.isAfterDay(end!)) {
            end = value.date;
          }
        }
      }
    });
    return end;
  }

  ///将给定的数据调整到7的倍数，这样方便运算
  Pair<DateTime, DateTime> _adjustTime(DateTime start, DateTime end) {
    final DateTime monthFirst = start.monthFirst();
    final DateTime monthEnd = end.monthLast();
    final int monthFirstWeek = monthFirst.weekday == 7 ? 0 : monthFirst.weekday;
    final int monthEndWeek = monthEnd.weekday == 7 ? 0 : monthEnd.weekday;

    DateTime startDateTime;
    DateTime endDateTime;
    if (option.sunFirst) {
      if (monthFirstWeek == 0) {
        startDateTime = monthFirst;
      } else {
        startDateTime = monthFirst.subtract(Duration(days: monthFirstWeek));
      }
      if (monthEndWeek == 6) {
        endDateTime = monthEnd;
      } else {
        endDateTime = monthEnd.add(Duration(days: 6 - monthEndWeek));
      }
    } else {
      if (monthFirstWeek == 1) {
        startDateTime = monthFirst;
      } else {
        int week = monthFirstWeek == 0 ? 7 : monthFirstWeek;
        startDateTime = monthFirst.subtract(Duration(days: week - 1));
      }
      if (monthEndWeek == 0) {
        endDateTime = monthEnd;
      } else {
        int week = monthEndWeek == 0 ? 7 : monthEndWeek;
        endDateTime = monthEnd.add(Duration(days: 7 - week));
      }
    }
    return Pair(startDateTime, endDateTime);
  }

  String key(DateTime time) {
    int year = time.year;
    int month = time.month;
    int day = time.day;
    return '$year${month.padLeft(2, '0')}${day.padLeft(2, '0')}';
  }

  @override
  Size get cellSize => Size(cellWidth, cellHeight);

  @override
  int get columnCount => _columnCount;

  @override
  int get rowCount => _rowCount;

  @override
  bool inRange(DateTime time) {
    return _nodeMap[key(time)] != null;
  }

  @override
  void onDragMove(Offset local, Offset global, Offset diff) {
    // if (diff.dx != 0 && diff.dy != 0) {
    //   throw ChartError('只支持单一方向');
    // }
    // var old = viewPort.translation;
    // Offset sc = viewPort.scroll(diff);
    // if (old.dx != sc.dx || old.dy != sc.dy) {
    //   if (old.dx != sc.dx) {
    //     context.dispatchEvent(AxisScrollEvent(this, [], sc.dx, null));
    //   } else {
    //     context.dispatchEvent(AxisScrollEvent(this, [], sc.dy, null));
    //   }
    //   repaint();
    // }
  }

  @override
  int get dimCount => 1;

  @override
  int getDimAxisCount(Dim dim) => 1;

  @override
  double convert(AxisDim dim, double ratio) {
    int dayCount = _startTime.diffDay(_endTime).abs();
    if (dayCount <= 0) {
      var rect=convert2(_startTime);
      if(dim.isCol){
        return rect.centerX;
      }
      return rect.centerY;
    }
    var c = (dayCount * ratio).round();
    var rect= convert2(_startTime.add(Duration(days: c)));
    if(dim.isCol){
      return rect.centerX;
    }
    return rect.centerY;
  }

  @override
  Rect convert2(DateTime time) {
    time = time.first();
    var node = _nodeMap[key(time)];
    if (node == null) {
      throw ChartError('当前给定的日期不在范围内');
    }
    return node.rect;
  }
}

abstract class CalendarCoord extends CoordView<Calendar> {
  CalendarCoord(super.context, super.props);

  Rect convert2(DateTime time);

  int get rowCount;

  int get columnCount;

  Size get cellSize;

  List<Offset> getMonthPolygon(int year, int month);

  List<Offset> getDateRangePolygon(DateTime start, DateTime end);

  bool inRange(DateTime time);

  @override
  bool get canFreeDrag => false;
}

class CalendarNode {
  final DateTime date;
  final int row;
  final int column;
  Rect rect = Rect.zero;

  CalendarNode(this.date, this.row, this.column);
}
