import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class SplitAreaDrawable with Drawable {
  static final Path _emptyPath = Path();
  static final _pool = Pool<SplitAreaDrawable>(() => SplitAreaDrawable._([], _emptyPath, null), (obj, fields) {
    obj.style = fields["style"];
    obj.pointData = fields["pointData"];
    obj.path = fields["path"];
  }, 10);

  static SplitAreaDrawable of(List<dynamic> pointData, Path path, AreaStyle? style) {
    return _pool.get({"style": style, "pointData": pointData, "path": path});
  }

  late List<dynamic> pointData;
  Path path;
  AreaStyle? style;

  SplitAreaDrawable._(dynamic data, this.path, this.style) {
    if (data is List<dynamic>) {
      this.pointData = data;
    } else {
      this.pointData = [data];
    }
  }

  @override
  void draw(Canvas2 canvas, Paint paint) {
    style?.drawPath(canvas, paint, path);
  }

  void recycle() {
    dispose();
    _pool.recycle(this);
  }
}
