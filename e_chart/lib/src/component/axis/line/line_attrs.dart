import 'dart:ui';

import 'package:e_chart/src/component/axis/axis_attrs.dart';
import 'package:e_chart/src/ext/offset_ext.dart';

///用于直线轴绘制
class LineAxisAttrs extends AxisAttrs {
  ///表示该直线轴的区域
  /// 其长度或宽度等于 [start] -[end] 之间的距离
  Rect rect;

  ///表示轴线的起始和结束位置(其距离一定==rect.width或者rect.height)
  Offset start;

  Offset end;

  LineAxisAttrs(
    this.rect,
    this.start,
    this.end, {
    super.scaleRatio,
    super.scrollX,
    super.scrollY,
    super.splitCount,
  });

  double get distance => start.distance2(end) * scaleRatio;

  double get distanceOrigin => start.distance2(end);

  @override
  AxisAttrs copy() {
    return LineAxisAttrs(
      rect,
      start,
      end,
      scaleRatio: scaleRatio,
      scrollX: scrollX,
      scrollY: scrollY,
      splitCount: splitCount,
    );
  }
}
