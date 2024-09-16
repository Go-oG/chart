import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

abstract class GForce {
  double width = 0;
  double height = 0;

  @mustCallSuper
  void initialize(Context context, Graph graph, LCG lcg, double width, double height) {
    this.width = width;
    this.height = height;
  }

  void force(double alpha);

  void onFinish() {}
}
