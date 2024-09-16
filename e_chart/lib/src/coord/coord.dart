import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///坐标系
abstract class Coord extends ValueNotifier2<Command> {
  late final String id;

  bool show;

  Color? backgroundColor;

  late LayoutParams layoutParams;

  ///自由拖拽
  bool freeDrag;
  bool freeLongPress;

  ///数据框选配置
  Brush? brush;

  ///ToolTip
  ToolTip? toolTip;

  ///指定坐标系方向 只有某些坐标系支持
  Direction direction;

  Coord({
    this.show = true,
    this.brush,
    this.toolTip,
    this.backgroundColor,
    this.freeDrag = false,
    this.freeLongPress = false,
    this.direction = Direction.vertical,
    LayoutParams? layoutParams,
    String? id,
  }) : super(Command.none) {
    this.layoutParams = layoutParams ?? LayoutParams.matchAll();
    this.id = isEmpty(id) ? randomId() : id!;
  }

  CoordType get type;

  ///通知数据更新
  void notifyUpdateData() {
    value = Command.updateData;
  }

  ///通知视图当前Series 配置发生了变化
  void notifyCoordConfigChange() {
    value = Command.configChange;
  }

  CoordView? toCoord(Context context) {
    return null;
  }

  ///返回当前坐标系全部的坐标维度
  List<AxisDim> get allAxisDim;

  ///通过AxisDim 返回对应坐标轴的配置
  BaseAxis getAxisConfig(AxisDim axisDim);

  Offset map(Context context, Offset offset, AxisDim dimX, AxisDim dimY) {
    var coord = context.viewManager.findCoord(id);
    if (coord == null) {
      throw ChartError("Coord not found");
    }
    return Offset(coord.convert(dimX, offset.dx), coord.convert(dimY, offset.dy));
  }
}

abstract class CoordView<T extends Coord> extends ChartViewGroup {
  T? _option;

  T get option => _option!;

  final ViewPort viewPort = ViewPort();

  double rotateValue = 0;

  ///存储内容的边界
  Rect contentBox = Rect.zero;

  BrushView? _brushView;


  CoordView(super.context, T props) : super(id: props.id) {
    _option = props;
    layoutParams = props.layoutParams;
  }

  CoordType get coordType => option.type;

  @override
  void onCreate() {
    super.onCreate();
    if (option.brush != null) {
      _brushView = BrushView(context, this, option.brush!);
      addView(_brushView!);
    }

    context.addActionCall(dispatchAction);
    registerCommandHandler();
    option.addListener(_handleCommand);
    viewPort.addListener(repaint);
  }

  @override
  void onDispose() {
    viewPort.removeListener(repaint);
    context.removeActionCall(dispatchAction);
    option.removeListener(_handleCommand);
    unregisterCommandHandler();
    _option = null;
    _brushView = null;
    super.onDispose();
  }

  ToolTip? findToolTip() {
    if (option.toolTip != null) {
      return option.toolTip;
    }
    return context.option.toolTip;
  }

  void _handleCommand(Command command) {
    onReceiveCommand(command);
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    requestLayout();
  }

  @override
  void dispatchDraw(Canvas2 canvas) {
    var hasRotate = rotateValue != 0;
    if (hasRotate) {
      canvas.save();
      canvas.translate(width / 2, height / 2);
      canvas.rotate(rotateValue * angleUnit);
      canvas.translate(-width / 2, -height / 2);
    }

    List<ChartView> vl = [];
    for (var child in children) {
      if (child is BrushView || child is ToolTipView) {
        vl.add(child);
      } else {
        drawChild(child, canvas);
      }
    }
    for (var child in vl) {
      drawChild(child, canvas);
    }
    if (hasRotate) {
      canvas.restore();
    }
  }

  @override
  void onDrawBackground(Canvas2 canvas) {
    Color? color = option.backgroundColor;
    if (color == null) {
      return;
    }
    mPaint.reset();
    mPaint.color = color;
    mPaint.style = PaintingStyle.fill;
    canvas.drawRect(boxBound.translate(-left, -top), mPaint);
  }

  @override
  bool get enableHover => true;

  @override
  bool get enableDrag => true;

  @override
  bool get enableClick => true;

  @override
  bool get enableScale => true;

  @override
  bool get enableLongPress => true;

  @override
  bool get canFreeDrag => option.freeDrag;

  @override
  bool get canFreeLongPress => option.freeLongPress;

  ///返回不包含BrushView、ToolTipView的子视图列表
  List<ChartView> getChildNotComponent() {
    List<ChartView> vl = [];
    for (var v in children) {
      if (v is! BrushView || v is! ToolTipView) {
        vl.add(v);
      }
    }
    return vl;
  }

  List<ChartView> getComponentChild() {
    List<ChartView> vl = [];
    for (var v in children) {
      if (v is BrushView || v is ToolTipView) {
        vl.add(v);
      }
    }
    return vl;
  }

  List<CoordChild> getCoordChildList() {
    List<CoordChild> list = [];
    for (var child in children) {
      if (child is CoordChild) {
        list.add(child as CoordChild);
      }
    }
    return list;
  }

  ///返回当前坐标系的维度(最低为1 最高为 2)
  int get dimCount;

  ///返回对应维度坐标轴的个数
  int getDimAxisCount(Dim dim);

  ///旋转坐标系
  void rotate(double angle) {
    if (rotateValue == angle) {
      return;
    }
    this.rotateValue = angle;
    repaint();
  }

  ///给定一个坐标维度和其百分比位置
  ///返回其对应的坐标点位置
  double convert(AxisDim dim, double ratio);

  // ///给定一个坐标维度和数值
  // ///返回其对应的坐标维多的位置
  // double convert2(AxisDim dim, dynamic value);
}

abstract class CircleCoordLayout<T extends CircleCoord> extends CoordView<T> {
  CircleCoordLayout(super.context, super.props);

  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    double w = widthSpec.size;
    double h = heightSpec.size;
    double d = option.radius.last.convert(min(w, h));
    setMeasuredDimension(d, d);
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    for (var child in children) {
      child.layout(0, 0, width, height);
    }
  }
}

abstract class CircleCoord extends Coord {
  List<SNumber> center;
  List<SNumber> radius;

  CircleCoord({
    this.radius = const [SNumber.zero, SNumber.percent(40)],
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    super.brush,
    super.toolTip,
    super.layoutParams,
    super.backgroundColor,
    super.id,
    super.show,
  });
}
