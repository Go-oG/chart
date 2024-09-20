import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/chart_scope.dart';
import 'package:flutter/foundation.dart';

///表格的通用配置
class ChartOption {
  final List<Geom> geoms;
  final ChartTitle? title;
  final Legend? legend;
  final List<Grid> gridList;
  final List<Polar> polarList;
  final List<Radar> radarList;
  final List<Parallel> parallelList;
  final List<Calendar> calendarList;
  final AnimateOption? animate;
  final ToolTip? toolTip;
  final ChartTheme theme;

  final Map<EventType, Set<VoidFun1<ChartEvent>>>? eventCall;
  final int doubleClickInterval;

  final int longPressTime;

  const ChartOption({
    required this.geoms,
    this.title,
    this.legend,
    this.gridList = const [],
    this.polarList = const [],
    this.radarList = const [],
    this.parallelList = const [],
    this.calendarList = const [],
    this.animate = const AnimateOption(),
    this.toolTip,
    this.theme = const ChartTheme(),
    this.eventCall,
    this.doubleClickInterval = 220,
    this.longPressTime = 280,
  });

  ChartOption copy({
    List<Geom>? geoms,
    ChartTitle? title,
    Legend? legend,
    List<Grid>? gridList,
    List<Polar>? polarList,
    List<Radar>? radarList,
    List<Parallel>? parallelList,
    List<Calendar>? calendarList,
    AnimateOption? animate,
    ToolTip? toolTip,
    ChartTheme? theme,
    Map<EventType, Set<VoidFun1<ChartEvent>>>? eventCall,
    int? doubleClickInterval,
    int? longPressTime,
  }) {
    return ChartOption(
      geoms: geoms ?? this.geoms,
      title: title ?? this.title,
      legend: legend ?? this.legend,
      gridList: gridList ?? this.gridList,
      polarList: polarList ?? this.polarList,
      radarList: radarList ?? this.radarList,
      parallelList: parallelList ?? this.parallelList,
      calendarList: calendarList ?? this.calendarList,
      animate: animate ?? this.animate,
      toolTip: toolTip ?? this.toolTip,
      theme: theme ?? this.theme,
      eventCall: eventCall ?? this.eventCall,
      doubleClickInterval: doubleClickInterval ?? this.doubleClickInterval,
      longPressTime: longPressTime ?? this.longPressTime,
    );
  }

  List<Coord> get coordList {
    return [
      ...gridList,
      ...polarList,
      ...radarList,
      ...calendarList,
      ...parallelList,
    ];
  }

  Context? get context {
    return chartScope.getContext(this);
  }

  @override
  int get hashCode => Object.hash(
        geoms,
        title,
        legend,
        gridList,
        polarList,
        radarList,
        parallelList,
        calendarList,
        animate,
        toolTip,
        theme,
        eventCall,
      );

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }

    return other is ChartOption &&
        listEquals(other.geoms, geoms) &&
        other.title == title &&
        other.legend == legend &&
        listEquals(other.gridList, gridList) &&
        listEquals(other.polarList, polarList) &&
        listEquals(other.radarList, radarList) &&
        listEquals(other.parallelList, parallelList) &&
        listEquals(other.calendarList, calendarList) &&
        other.animate == animate &&
        other.toolTip == toolTip &&
        other.theme == theme &&
        other.eventCall == eventCall;
  }
}
