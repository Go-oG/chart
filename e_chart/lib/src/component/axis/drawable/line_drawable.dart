import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class AxisLineDrawable with Drawable {
  static final _pool =
      Pool<AxisLineDrawable>(() => AxisLineDrawable._([], 0, 0, Offset.zero, Offset.zero, null), (obj, fields) {
    obj.style = fields["style"];
    obj.end = fields["end"];
    obj.start = fields["start"];
    obj.pointData = fields["pointData"];
    obj.index = fields["index"];
    obj.maxIndex = fields["maxIndex"];
  }, 20);

  //存储当前线段对应的端点数据
  List<dynamic> pointData;

  //存储当前线段的索引
  int index;

  //存储整个坐标轴的最大索引
  int maxIndex;

  //起始端点坐标
  Offset start;

  //结束端点坐标
  Offset end;
  LineStyle? style;

  static AxisLineDrawable of(
      List<dynamic> pointData, int index, int maxIndex, Offset start, Offset end, LineStyle? style) {
    return _pool.get(
        {"style": style, "end": end, "start": start, "pointData": pointData, "index": index, "maxIndex": maxIndex});
  }

  AxisLineDrawable._(this.pointData, this.index, this.maxIndex, this.start, this.end, this.style);

  @override
  void draw(Canvas2 canvas, Paint paint) {
    style?.drawLine(canvas, paint, start, end);
  }

  @override
  void dispose() {
    super.dispose();
    pointData = List.empty();
    style = null;
    start = end = Offset.zero;
  }

  void recycle() {
    _pool.recycle(this);
  }
}

class AxisCurveDrawable with Drawable {
  static final _pool =
      Pool<AxisCurveDrawable>(() => AxisCurveDrawable._([], 0, 0, Offset.zero, 0, 0, 0, null), (obj, fields) {
    obj.style = fields["style"];
    obj.sweepAngle = fields["sweepAngle"];
    obj.startAngle = fields["startAngle"];
    obj.radius = fields["radius"];
    obj.center = fields["center"];
    obj.index = fields["index"];
    obj.maxIndex = fields["maxIndex"];
    obj.pointData = fields["pointData"];
  }, 20);

  static AxisCurveDrawable of(List<dynamic> pointData, int index, int maxIndex, Offset center, num radius,
      num startAngle, num sweepAngle, LineStyle? style) {
    return _pool.get({
      "pointData": pointData,
      "index": index,
      "maxIndex": maxIndex,
      "center": center,
      "radius": radius,
      "startAngle": startAngle,
      "sweepAngle": sweepAngle,
      "style": style
    });
  }

  late List<dynamic> pointData;
  int index;
  int maxIndex;
  Offset center;
  num radius;
  num startAngle;
  num sweepAngle;
  LineStyle? style;

  AxisCurveDrawable._(
    dynamic data,
    this.index,
    this.maxIndex,
    this.center,
    this.radius,
    this.startAngle,
    this.sweepAngle,
    this.style,
  ) {
    if (data is List<dynamic>) {
      pointData = data;
    } else {
      pointData = [data];
    }
  }

  @override
  void draw(Canvas2 canvas, Paint paint) {
    style?.drawArc2(canvas, paint, radius, startAngle, sweepAngle, center);
  }

  @override
  void dispose() {
    super.dispose();
    style = null;
    pointData = List.empty();
  }

  void recycle() {
    dispose();
    _pool.recycle(this);
  }
}
