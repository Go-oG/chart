import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///标记抽象表示
///每个图表必须要有一个Geom
abstract class Geom extends ViewNotifier with GeomMix,TransformMix {
  late final String id;
  late String coordId;
  List<RawData> dataSet;

  ///布局参数
  late LayoutParams layoutParams;
  AnimateOption? animation; //动画
  ///该属性只在某些图表生效
  Color? backgroundColor;
  ToolTip? tooltip;

  // 是否裁剪
  bool clip;

  ///是否使用单独的层
  bool cacheLayer;

  ///Geom的索引 在Context中进行分配
  int geomIndex = -1;

  Geom(
    this.dataSet,
    this.coordId, {
    LayoutParams? layoutParams,
    this.animation,
    this.tooltip,
    this.backgroundColor,
    this.clip = true,
    this.cacheLayer = false,
    String? id,
  }) {
    this.id = isEmpty(id) ? randomId() : id!;
    this.layoutParams = layoutParams ?? LayoutParams.matchAll();
  }

  ///返回承载该Geom的渲染视图
  ///如果返回null,那么将会调用[GeomFactory]的相关方法
  ///来创建视图，如果无法创建视图则会抛错
  ChartView? toView(Context context) {
    return null;
  }

  ///获取动画参数
  ///[count]当前需要动画的节点数，用于判断是否需要执行动画
  AnimateOption? getAnimation([int count = -1]) {
    var attr = animation;
    if (attr == null) {
      return null;
    }
    if (count > 0 && attr.threshold > 0 && attr.threshold < count) {
      return null;
    }
    return attr;
  }

  ///负责将一个原始数据转为节点,该节点只用考虑自身的数据即可
  DataNode toNode(RawData data) {
    var value = tryGetValue(data);
    return DataNode(this, data, value: value);
  }

  ///尝试获取单一Value值
  ///一般情况下该方法用于只有单个数据值的对象
  double? tryGetValue(RawData data) {
    for (var pos in allPos) {
      var value = _takeValue(data.get2(pos.field));
      if (value != null) {
        return value;
      }
    }
    return _takeValue(data.get2("value"));
  }

  double? _takeValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is List) {
      for (var item in value) {
        if (item == null) {
          continue;
        }
        if (item is num) {
          return item.toDouble();
        }
      }
    }
    return null;
  }

  GeomType get geomType;

  Coord? findCoord(Context context) {
    return context.viewManager.findCoord2(coordId);
  }

  @override
  void dispose() {
    animation = null;
    super.dispose();
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Geom && other.id == id;
  }
}
