import 'dart:math';

export 'package:dart_dagre/dart_dagre.dart';

export 'src/action/index.dart';
export 'src/animation/index.dart';
export 'src/chart.dart';
export 'src/charts/index.dart';
export 'src/component/index.dart';
export 'src/coord/index.dart' hide CalendarCoordImpl, GridCoordImpl, ParallelCoordImpl, PolarCoordImpl, RadarCoordImpl;
export 'src/core/index.dart';
export 'src/data/index.dart';
export 'src/ext/index.dart';
export 'src/geom/index.dart';
export 'src/mixins/attr_mixin.dart';
export 'src/model/error.dart';
export 'src/model/index.dart';
export 'src/option/index.dart';
export 'src/shape/index.dart';
export 'src/types.dart';
export 'src/utils/index.dart';

/// 一般用于角度转弧度
const angleUnit = pi / 180;

const halfPi = pi / 2;

///这里取53 是为了兼容Web
const int maxInt = 2 ^ 53 - 1;

///double 之间精度
const double accuracy = 0.00000001;

///用于确定比例尺缩放相关（映射标准步长值）
///更改该参数将影响所有坐标轴的缩放步进值
///每个数值必须在(0,1]之间
///通常常用的可以为[0.1,0.2.0.3.0.4,0.5,1]
List<num> scaleSteps = List.from([0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1], growable: false);
