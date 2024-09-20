import 'package:e_chart/e_chart.dart';

abstract class ChartEvent {
  const ChartEvent();

  EventType get eventType;

  void dispose() {}
}

class EventInfo {
  ///当前图形元素所属的组件名称，
  final ComponentType componentType;
  final DataNode dataNode;

  ///传入的原始数据项
  final RawData data;

  EventInfo(
    this.componentType,
    this.dataNode,
    this.data,
  );

  @override
  int get hashCode {
    return Object.hash(componentType, data);
  }

  @override
  bool operator ==(Object other) {
    return other is EventInfo && other.componentType == componentType && other.data == data;
  }

  @override
  String toString() {
    return "componentType:$componentType\n"
        "data:$data ";
  }
}
