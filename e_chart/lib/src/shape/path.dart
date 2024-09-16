import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PathShape extends CShape {
  Path mPath;
  PathShape(this.mPath);

  @override
  Path buildPath() => mPath;

  @override
  bool get isClosed => false;

  @override
  void fill(Attrs attr) {}
}
