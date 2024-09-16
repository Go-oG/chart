import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class TickDrawable with Drawable {
  static final _pool =
      Pool<TickDrawable>(() => TickDrawable._([], 0, 0, Offset.zero, Offset.zero, null, []), (obj, fields) {
    obj.style = fields["style"];
    obj.end = fields["end"];
    obj.start = fields["start"];
    obj.pointData = fields["pointData"];
    obj.index = fields["index"];
    obj.maxIndex = fields["maxIndex"];
    obj.minorList = fields["minorList"];
  }, 20);

  static TickDrawable of(
    List<dynamic> pointData,
    int index,
    int maxIndex,
    Offset start,
    Offset end,
    LineStyle? style, [
    List<TickDrawable>? minorList,
  ]) {
    return _pool.get({
      "style": style,
      "end": end,
      "start": start,
      "pointData": pointData,
      "index": index,
      "maxIndex": maxIndex,
      "minorList": minorList
    });
  }

  ///数据可能为空
  late List<dynamic> pointData;
  int index;
  int maxIndex;
  Offset start;
  Offset end;
  LineStyle? style;

  List<TickDrawable>? minorList;

  TickDrawable._(
    dynamic data,
    this.index,
    this.maxIndex,
    this.start,
    this.end,
    this.style, [
    this.minorList = const [],
  ]) {
    if (data is List<dynamic>) {
      this.pointData = data;
    } else {
      this.pointData = [data];
    }
  }

  @override
  void draw(Canvas2 canvas, Paint paint) {
    style?.drawLine(canvas, paint, start, end);
    minorList?.each((tick, p1) {
      tick.draw(canvas, paint);
    });
  }

  @override
  void dispose() {
    super.dispose();
    minorList?.each((p0, p1) {
      p0.dispose();
    });
    minorList = [];
  }

  void recycle() {
    dispose();
    _pool.recycle(this);
  }
}
