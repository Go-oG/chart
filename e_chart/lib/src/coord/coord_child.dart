import 'package:e_chart/e_chart.dart';

abstract class CoordChild {
  ///返回指定坐标轴上文字字符最长的文本
  DynamicText getAxisMaxText(CoordType type, AxisDim axisDim);

  ///返回指定坐标轴上的极值
  Iterable<dynamic> getAxisExtreme(CoordType type, AxisDim axisDim);

  Iterable<dynamic> getViewPortAxisExtreme(CoordType type, AxisDim axisDim, BaseScale scale);

  ///同步滚动偏移量 一般用在笛卡尔坐标系里面实现手势滚动
  void syncScroll(CoordType type, double scrollX, double scrollY);
}
