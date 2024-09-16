import 'package:e_chart/e_chart.dart';

import '../event.dart';
import '../event_dispatcher.dart';

abstract class BrushEvent extends ChartEvent {
  final String coordId;
  final String brushId;
  List<BrushArea> areas;

  BrushEvent(
    this.coordId,
    this.brushId,
    this.areas,
  );
}

///框选过滤
class BrushFilterEvent extends BrushEvent {
  BrushFilterEvent(super.coordId, super.coordViewId, super.coordType);

  @override
  EventType get eventType => EventType.brushUpdate;
}

///框选坐标轴高亮 一般用于平行坐标系
class BrushAxisHighLight {}

///框选高亮
class BrushHighLight {}
