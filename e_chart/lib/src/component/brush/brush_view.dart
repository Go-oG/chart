import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///框选
///BrushView 只能在坐标系中出现
///覆盖在单个坐标系的最顶层(比TooltipView 低)
class BrushView extends GestureView {
  CoordView? _coord;
  CoordView get coord => _coord!;
  Brush? _brush;

  Brush get brush => _brush!;
  List<BrushArea> _brushList = [];
  late final BrushEvent _updateEvent;

  BrushView(super.context, this._coord, this._brush) {
    layoutParams = LayoutParams.matchAll();
    _updateEvent = BrushEvent(EventOrder.update, coord.option.id, brush, []);
  }

  @override
  set layoutParams(LayoutParams p) {
    if (!p.width.isMatch || !p.height.isMatch) {
      throw ChartError("BrushView only support match all");
    }
    super.layoutParams = p;
  }

  @override
  void onCreate() {
    super.onCreate();
    // brush.addListener(handleBrushCommand);
    context.addActionCall(_handleAction);
  }

  void handleBrushCommand() {
    // var c = brush.value;
    // if (c.code == Command.showBrush.code || c.code == Command.hideBrush.code) {
    //   repaint();
    //   return;
    // }
    // if (c.code == Command.clearBrush.code || c.code == Command.configChange.code) {
    //   _brushList = [];
    //   repaint();
    //   return;
    // }
  }

  bool _handleAction(ChartAction action) {
    if (!brush.enable) {
      return false;
    }
    if (action is BrushClearAction) {
      // if (action.brushId == brush.id) {
      //   _brushList = [];
      //   repaint();
      //   return true;
      // }
      return false;
    }
    if (action is BrushAction) {
      if (_handleActionList(action.actionList) > 0) {
        _sendBrushEvent(_brushList);
        repaint();
      }
      return false;
    }
    if (action is BrushEndAction) {
      if (_handleActionList(action.actionList) > 0) {
        repaint();
      }
      return false;
    }
    return false;
  }

  int _handleActionList(List<BrushActionData> list) {
    int c = 0;
    // for (var data in list) {
    //   if (data.brushId != brush.id) {
    //     continue;
    //   }
    //   if (!brush.supportMulti) {
    //     _brushList.clear();
    //   }
    //   _brushList.add(BrushArea(data.brushType, data.range));
    //   c++;
    // }
    return c;
  }

  void _sendBrushEvent(List<BrushArea> brushList, [bool redraw = true]) {
    _updateEvent.areas = brushList;
    context.dispatchEvent(_updateEvent);
    if (redraw) {
      repaint();
    }
  }

  @override
  void onDispose() {
    context.removeActionCall(_handleAction);
    _coord = null;
    _brush = null;
    _brushList = [];
    super.onDispose();
  }

  @override
  void onDraw(Canvas2 canvas) {
    if (!brush.enable) {
      return;
    }
    for (var area in _brushList) {
      brush.areaStyle.drawPath(canvas, mPaint, area.path);
      brush.borderStyle?.drawPath(canvas, mPaint, area.path);
    }
    var ol = _ol;
    if (ol.isNotEmpty) {
      brush.areaStyle.drawPolygon(canvas, mPaint, ol);
      brush.borderStyle?.drawPolygon(canvas, mPaint, ol, true);
    }
  }

  ///======手势处理=======
  List<Offset> _ol = [];
  Offset? _first;
  Offset? _last;

  @override
  void onClick(Offset local, Offset global) {
    if (!brush.enable) {
      return;
    }
    local = local.translate(scrollX, scrollY);
    if (brush.removeOnClick && !brush.supportMulti && _brushList.isNotEmpty) {
      var first = _brushList.first;
      if (!first.path.contains(local)) {
        _brushList = [];
        repaint();
      }
    }
  }

  @override
  void onDragStart(Offset local, Offset global) {
    local = local.translate(scrollX, scrollY);
    _ol.clear();
    _first = null;
    if (!brush.enable) {
      return;
    }
    _first = local;
  }

  @override
  void onDragMove(Offset local, Offset global, Offset diff) {
    if (!brush.enable) {
      _ol = [];
      _first = null;
      return;
    }
    local = local.translate(scrollX, scrollY);

    var first = _first;
    if (first == null) {
      throw ChartError("状态异常");
    }
    _last = local;
    if (brush.type != BrushType.polygon) {
      _ol = buildArea(first, local);
    } else {
      _ol.add(local);
    }
    List<BrushArea> areaList = List.from(_brushList);
    if (_ol.isNotEmpty) {
      areaList.add(BrushArea(brush.type, _ol));
    }
    _sendBrushEvent(areaList);
  }

  @override
  void onDragEnd() {
    if (!brush.enable) {
      _ol = [];
      _first = null;
      _last = null;
      return;
    }
    var first = _first;
    var last = _last;
    if (first == null || last == null) {
      throw ChartError("状态异常");
    }
    if (brush.type != BrushType.polygon) {
      _ol = buildArea(first, last);
    }
    if (!brush.supportMulti) {
      _brushList = [];
    }
    if (_ol.isNotEmpty) {
      _brushList.add(BrushArea(brush.type, _ol));
    }
    _ol = [];
    _first = null;
    _last = null;
  }

  List<Offset> buildArea(Offset first, Offset offset) {
    if (brush.type == BrushType.rect) {
      return [
        first,
        Offset(offset.dx, first.dy),
        offset,
        Offset(first.dx, offset.dy),
      ];
    }

    if (brush.type == BrushType.vertical) {
      return [
        Offset(scrollX, first.dy),
        Offset(scrollX + width, first.dy),
        Offset(scrollX + width, offset.dy),
        Offset(scrollX, offset.dy),
      ];
    }
    if (brush.type == BrushType.horizontal) {
      return [
        Offset(first.dx, height),
        Offset(first.dx, scrollY),
        Offset(offset.dx, scrollY),
        Offset(offset.dx, height),
      ];
    }
    return [];
  }
}
