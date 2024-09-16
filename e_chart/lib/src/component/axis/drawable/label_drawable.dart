import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class AxisLabelDrawable with Drawable {
  static final _pool = Pool<AxisLabelDrawable>(() => AxisLabelDrawable._(0, 0, Text2.empty, []), (obj, fields) {
    obj.index = fields["index"];
    obj.maxIndex = fields["maxIndex"];
    obj.label = fields["label"];
    obj.minorLabel = fields["minorLabel"];
  }, 20);

  static AxisLabelDrawable of(int index, int maxIndex, Text2 label, [List<AxisLabelDrawable> minorLabel = const []]) {
    return _pool.get({"index": index, "maxIndex": maxIndex, "label": label, "minorLabel": minorLabel});
  }

  int index;
  int maxIndex;
  Text2 label;
  List<AxisLabelDrawable> minorLabel;

  AxisLabelDrawable._(
    this.index,
    this.maxIndex,
    this.label, [
    this.minorLabel = const [],
  ]);

  @override
  void draw(Canvas2 canvas, Paint paint) {
    label.draw(canvas, paint);
    each(minorLabel, (p0, p1) {
      p0.draw(canvas, paint);
    });
  }

  @override
  void dispose() {
    super.dispose();
    label.dispose();
    each(minorLabel, (p0, p1) {
      p0.dispose();
    });
    minorLabel = List.empty();
  }

  void recycle() {
    dispose();
    _pool.recycle(this);
  }
}
