import 'dart:ui' as ui;

import 'package:e_paths/src/path.dart';

import 'Cubic.dart';

class PathLerp {
  final Path start;
  final Path end;

  List<Cubic> _startList = [];
  List<Cubic> _endList = [];

  PathLerp(this.start, this.end) {
    _compute();
  }

  void _compute() {}

  ui.Path lerp(double progress) {
    throw UnimplementedError();
  }
}
