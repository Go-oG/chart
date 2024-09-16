import 'dart:ui';

import 'package:e_chart/e_chart.dart';

enum CoordType {
  grid,
  polar,
  parallel,
  radar,
  calendar,
  custom;

  bool isGrid() {
    return this == grid;
  }

  bool isPolar() {
    return this == CoordType.polar;
  }

  bool isParallel() {
    return this == CoordType.parallel;
  }

  bool isRadar() {
    return this == CoordType.radar;
  }

  bool isCalendar() {
    return this == CoordType.calendar;
  }

  bool isCustom() {
    return this == CoordType.custom;
  }
}

enum LayoutType {
  ///该布局方式将拒绝所有的动画(执行普通布局)
  none,

  ///该布局方式表示触发类型为全量布局
  ///使用的动画参数类型为普通参数
  layout,

  ///该布局方式表示是更新布局
  ///使用的动画参数为带update的前缀
  update,
}

enum ComponentType {
  geom,
  markLine,
  markPoint,
  timeLine,
}

enum StackType { sum, split }

///时间分割类型
enum TimeType { year, month, week, day, hour, minute, sec }

enum DataType { nodeData, edgeData }

enum DragType { longPress, drag }

class LineType {
  static const LineType line = LineType(-1);
  static const LineType after = LineType(1);
  static const LineType step = LineType(0.5);
  static const LineType before = LineType(0);
  final double ratio;

  const LineType(this.ratio);

  bool isStep() {
    return ratio >= 0 && ratio <= 1;
  }

  List<Offset> convert(Offset start, Offset end, Direction direction) {
    if (ratio < 0 || ratio > 1) {
      return [start, end];
    }
    if (direction == Direction.horizontal) {
      List<Offset> list = [start];
      if (ratio > 0) {
        list.add(Offset(start.dx + (end.dx - start.dx) * ratio, start.dy));
      }
      if (ratio < 1) {
        list.add(Offset(start.dx + (end.dx - start.dx) * ratio, end.dy));
      }
      list.add(end);
      return list;
    }

    List<Offset> list = [start];

    if (ratio > 0) {
      list.add(Offset(start.dx, start.dy + (end.dy - start.dy) * ratio));
    }
    if (ratio < 1) {
      list.add(Offset(end.dx, start.dy + (end.dy - start.dy) * ratio));
    }
    list.add(end);
    return list;
  }
}
