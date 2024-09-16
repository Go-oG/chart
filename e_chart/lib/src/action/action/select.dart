import 'package:e_chart/e_chart.dart';

class SelectAction extends ChartAction{
  final List<int> geomIndex;
  final List<String> seriesId;
  final List<int> dataIndex;
  final List<String> dataId;

  SelectAction({
    this.geomIndex = const [],
    this.seriesId = const [],
    this.dataIndex = const [],
    this.dataId = const [],
    super.fromUser,
  });
}