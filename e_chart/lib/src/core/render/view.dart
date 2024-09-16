import 'dart:async';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'render_root.dart';

abstract class ChartView with ViewFrame {
  late final String id;

  Context context;

  AttachInfo? _attachInfo;

  AttachInfo get attachInfo {
    return _attachInfo!;
  }

  set attachInfo(AttachInfo info) {
    _attachInfo = info;
  }

  ChartView(this.context, {String? id}) {
    this.id = isEmpty(id) ? randomId() : id!;
  }

  @protected
  ViewParent? mParent;

  ViewParent? get parent => mParent;

  set parent(ViewParent? p) => mParent = p;

  @protected
  ViewOverLay? mOverlay;

  @protected
  late Paint mPaint = Paint();

  ///存储当前节点的布局属性
  LayoutParams layoutParams = LayoutParams.matchAll();

  double alpha = 1;

  bool get needNewLayer => false;

  bool _forceLayout = true;

  bool get isForceLayout => _forceLayout;

  void forceLayout() {
    _forceLayout = true;
  }

  ///后续节点更新时使用
  bool _forceDraw = true;

  bool get isNeedDraw => _forceDraw;

  @override
  bool setVisibility(ViewVisibility vb) {
    var old = visibility;
    bool res = super.setVisibility(vb);
    if (res) {
      parent?.childVisibilityChange(this, old);
    }
    return res;
  }

  FutureOr<void> measure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    onMeasure(widthSpec, heightSpec);
  }

  FutureOr<void> onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    LayoutParams lp = layoutParams;
    double w = _measureSelfWithParent(widthSpec, lp.hPadding, lp.width);
    double h = _measureSelfWithParent(heightSpec, lp.vPadding, lp.height);
    setMeasuredDimension(w, h);
  }

  double _measureSelfWithParent(MeasureSpec parentSpec, double padding, SizeParams selfParams) {
    if (selfParams.isExactly) {
      return selfParams.size.number.toDouble();
    }
    if (selfParams.isWrap) {
      return padding;
    }
    //match parent
    var mode = parentSpec.mode;
    if (mode == SpecMode.exactly) {
      return parentSpec.size;
    }
    return padding;
  }

  double measureSelfSize(MeasureSpec parentSpec, SizeParams selfParams, double pendingSize) {
    if (selfParams.isExactly) {
      return selfParams.size.number.toDouble();
    }
    if (selfParams.isWrap) {
      return pendingSize;
    }

    //match parent
    var mode = parentSpec.mode;
    if (mode == SpecMode.atMost) {
      return pendingSize;
    }
    if (mode == SpecMode.exactly) {
      return parentSpec.size;
    }

    return pendingSize;
  }

  FutureOr<void> layout(double l, double t, double r, double b) {
    var oldL = left;
    var oldT = top;
    var oldR = right;
    var oldB = bottom;

    bool changed = setFrame(l, t, r, b);
    if (changed || _forceLayout) {
      onLayout(changed, l, t, r, b);
      onLayoutChange(l, t, r, b, oldL, oldT, oldR, oldB);
    }
    _forceLayout = false;
  }

  @protected
  bool setFrame(double left, double top, double right, double bottom) {
    bool changed = false;
    if (diff(left, top, right, bottom)) {
      changed = true;
      double oldWidth = width;
      double oldHeight = height;
      double newWidth = right - left;
      double newHeight = bottom - top;

      this.left = left;
      this.top = top;
      this.right = right;
      this.bottom = bottom;

      var parent = this.parent;
      if (parent is ChartViewGroup) {
        globalTop = parent.globalTop + top;
        globalLeft = parent.globalLeft + left;
      } else {
        globalTop = top;
        globalLeft = left;
      }
      bool sizeChange = diffSize(left, top, right, bottom);
      if (sizeChange) {
        _sizeChange(newWidth, newHeight, oldWidth, oldHeight);
        repaint();
      }
      if (visibility.isShow) {
        if (!sizeChange) {
          repaint();
        }
        parent?.redrawParentCaches();
      }
    }
    return changed;
  }

  FutureOr<void> onLayout(bool changed, double left, double top, double right, double bottom) {}

  void onLayoutChange(double left, double top, double right, double bottom, double oldLeft, double oldTop,
      double oldRight, double oldBottom) {}

  void _sizeChange(double newWidth, double newHeight, double oldWidth, double oldHeight) {
    onSizeChange(newWidth, newHeight, oldWidth, oldHeight);
  }

  void onSizeChange(double newWidth, double newHeight, double oldWidth, double oldHeight) {}

  void draw(Canvas2 canvas) {
    if (visibility.isHide) {
      return;
    }

    //TODO 检查缓存 以及是否需要二次绘制
    _drawBackground(canvas);
    onDraw(canvas);
    dispatchDraw(canvas);
    drawOverlay(canvas);
    onDrawForeground(canvas);
    drawFocusHighlight(canvas);
  }

  void _drawBackground(Canvas2 canvas) {
    final double scrollX = this.scrollX;
    final double scrollY = this.scrollY;
    if (scrollX == 0 && scrollY == 0) {
      onDrawBackground(canvas);
    } else {
      canvas.translate(scrollX, scrollY);
      onDrawBackground(canvas);
      canvas.translate(-scrollX, -scrollY);
    }
  }

  @protected
  void onDrawBackground(Canvas2 canvas) {}

  @protected
  void onDraw(Canvas2 canvas) {}

  @protected
  void dispatchDraw(Canvas2 canvas) {}

  @protected
  void drawOverlay(Canvas2 canvas) {
    mOverlay?.getOverlayView().dispatchDraw(canvas);
  }

  @protected
  void onDrawForeground(Canvas2 canvas) {}

  @protected
  void drawFocusHighlight(Canvas2 canvas) {}

  void computeScroll() {}

  void requestLayout() {
    //ClearCache
    // if (mMeasureCache != null) mMeasureCache.clear();
    var attachInfo = _attachInfo;
    if (attachInfo != null) {
      var vrl = attachInfo.viewRequestingLayout;
      if (vrl == null) {
        attachInfo.viewRequestingLayout = this;
      } else {
        if (vrl == this) {
          return;
        }
        attachInfo.viewRequestingLayout = this;
      }
    }
    _forceLayout = true;
    _forceDraw = true;
    mParent?.requestLayout();
  }

  void repaint() {
    _forceDraw = true;
    var parent = this.parent;
    if (parent is ChartViewGroup) {
      parent.repaint();
    }
  }

  void clearFocus() {}

  @protected
  void clearFocusInternal(ChartView? focused, bool propagate, bool refocus) {}

  void unFocus(ChartView focused) {
    clearFocusInternal(focused, false, false);
  }

  bool hasFocus() {
    return false;
  }

  ///=========生命周期回调方法开始==================

  ///该回调只会发生在视图创建后，且只会回调一次
  void dispatchAttachInfo(AttachInfo attachInfo) {
    _attachInfo = attachInfo;
  }

  void created() {
    onCreate();
  }

  void onCreate() {}

  void attachToWindow() {
    onViewAttachToWindow();
  }

  void onViewAttachToWindow() {}

  void detachFromWindow() {
    onViewDetachFromWindow();
  }

  void onViewDetachFromWindow() {}

  ///由Context负责回调
  ///当该方法被调用时标志着当前View即将被销毁
  ///你可以在这里进行资源释放等操作
  void dispose() {
    clearCommand();
    _defaultCommandCallback = null;
    unBindGeom();
    onDispose();
  }

  void onDispose() {}

  ///=============处理geom和其绑定时相关的操作=============
  Geom? _geom;

  ///存储命令执行相关的操作
  Map<Command, VoidFun1<Command>> _commandMap = {};

  void clearCommand() {
    _commandMap = {};
  }

  void registerCommand(Command c, VoidFun1<Command> callback, [bool allowReplace = true]) {
    var old = _commandMap[c];
    if (!allowReplace && callback != old) {
      throw ChartError('not allow replace');
    }
    _commandMap[c] = callback;
  }

  void removeCommand(int code) {
    _commandMap.remove(code);
  }

  ///绑定Geom 主要是将Geom相关的命令传递到当前View
  VoidFun1<Command>? _defaultCommandCallback;

  void bindGeom(covariant Geom geom) {
    unBindGeom();
    _geom = geom;
    _defaultCommandCallback = (v) {
      onReceiveCommand(v);
    };
    geom.addListener(_defaultCommandCallback!);
    registerCommandHandler();
  }

  void unBindGeom() {
    _commandMap.clear();
    if (_defaultCommandCallback != null) {
      _geom?.removeListener(_defaultCommandCallback!);
    }
    _geom = null;
  }

  void registerCommandHandler() {
    _commandMap[Command.updateData] = onUpdateDataCommand;
    _commandMap[Command.invalidate] = onInvalidateCommand;
    _commandMap[Command.reLayout] = onRelayoutCommand;
    _commandMap[Command.configChange] = onGeomConfigChangeCommand;
  }

  void unregisterCommandHandler() {
    _commandMap.remove(Command.updateData);
    _commandMap.remove(Command.invalidate);
    _commandMap.remove(Command.reLayout);
    _commandMap.remove(Command.configChange);
  }

  void onReceiveCommand(covariant Command? c) {
    if (c == null) {
      return;
    }

    var op = _commandMap[c];
    if (op == null) {
      Logger.w('$c 无法找到能出来该命令相关的回调');
      return;
    }
    op.call(c);
  }

  void onInvalidateCommand(covariant Command c) {
    repaint();
  }

  void onRelayoutCommand(covariant Command c) {
    requestLayout();
  }

  void onGeomConfigChangeCommand(covariant Command c) {}

  void onUpdateDataCommand(covariant Command c) {
    repaint();
  }

  ///分配索引
  ///返回值表示消耗了好多的索引
  int allocateDataIndex(int index) {
    return 0;
  }

  ///是否忽略索引分配
  bool ignoreAllocateDataIndex() {
    return false;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is ChartView && other.id == id;
  }

  bool get useZeroWhenMeasureSpecModeIsUnLimit => false;
}

///存储View中和视图有关联的数据
mixin ViewFrame {
  double _left = 0;

  double get left => _left;

  set left(double l) => _left = l;

  double _top = 0;

  double get top => _top;

  set top(double t) => _top = t;

  double _right = 0;

  double get right => _right;

  set right(double r) => _right = r;

  double _bottom = 0;

  double get bottom => _bottom;

  set bottom(double b) => _bottom = b;

  double _globalLeft = 0;

  double get globalLeft => _globalLeft;

  set globalLeft(double gl) => _globalLeft = gl;

  double _globalTop = 0;

  double get globalTop => _globalTop;

  set globalTop(double gt) => _globalTop = gt;

  double _measureWidth = 0;

  double get measureWidth => _measureWidth;

  double _measureHeight = 0;

  double get measureHeight => _measureHeight;

  void setMeasuredDimension(double measureWidth, double measureHeight) {
    _measureWidth = measureWidth;
    _measureHeight = measureHeight;
  }

  double get centerX => width / 2.0;

  double get centerY => height / 2.0;

  double get width {
    return right - left;
  }

  double get height {
    return bottom - top;
  }

  double get shortSide {
    return width > height ? height : width;
  }

  double get longSide {
    return width >= height ? width : height;
  }

  Rect get boxBound {
    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect get globalBound {
    return Rect.fromLTWH(globalLeft, globalTop, width, height);
  }

  Offset toLocal(Offset global) {
    return Offset(global.dx - _globalLeft, global.dy - _globalTop);
  }

  Offset toGlobal(Offset local) {
    return Offset(local.dx + _globalLeft, local.dy + _globalTop);
  }

  double _scrollX = 0;

  double get scrollX => _scrollX;

  set scrollX(double sx) => _scrollX = sx;

  double _scrollY = 0;

  double get scrollY => _scrollY;

  set scrollY(double sy) => _scrollY = sy;

  void setScroll(double? sx, double? sy) {
    if (sx != null) {
      _scrollX = sx;
    }
    if (sy != null) {
      _scrollY = sy;
    }
  }

  void scrollTo(double sx, double sy) {
    _scrollX = sx;
    _scrollY = sy;
  }

  void scrollOff(double dx, double dy) {
    _scrollX += dx;
    _scrollY += dy;
  }

  double _translationX = 0;

  double get translationX => _translationX;

  set translationX(double tx) => _translationX = tx;

  double _translationY = 0;

  double get translationY => _translationY;

  set translationY(double ty) => _translationY = ty;

  double _scaleX = 1;

  double get scaleX => _scaleX;

  set scaleX(double sx) => _scaleX = sx;

  double _scaleY = 1;

  double get scaleY => _scaleY;

  set scaleY(double sy) => _scaleY = sy;

  set scale(double scale) {
    scaleX = scaleY = scale;
  }

  ViewVisibility _visibility = ViewVisibility.visible;

  bool setVisibility(ViewVisibility vb) {
    if (_visibility == vb) {
      return false;
    }
    _visibility = vb;
    return true;
  }

  ViewVisibility get visibility {
    return _visibility;
  }

  bool diff(double l, double t, double r, double b) {
    return l != left || t != top || r != right || b != bottom;
  }

  bool diffSize(double l, double t, double r, double b) {
    return (r - l) != width || (b - t) != height;
  }

  ///获取当前视图自身的可视区域范围
  ///当前可视区域范围只和Scroll有关
  Rect get selfViewPort {
    return Rect.fromLTRB(scrollX, scrollY, width, height);
  }
}

final class AttachInfo {
  RenderRoot root;

  AttachInfo(this.root);

  ChartView? viewRequestingLayout;
}

final class MeasureSpec {
  final SpecMode mode;
  final double size;

  const MeasureSpec._(this.mode, this.size);

  const MeasureSpec.atMost(double size) : this._(SpecMode.atMost, size);

  const MeasureSpec.unLimit(double size) : this._(SpecMode.unLimit, size);

  const MeasureSpec.exactly(double size) : this._(SpecMode.exactly, size);

  @override
  String toString() {
    return "mode:$mode size:$size";
  }
}

enum SpecMode {
  atMost,
  unLimit,
  exactly;

  bool get isExactly {
    return this == SpecMode.exactly;
  }

  bool get isAtMost {
    return this == SpecMode.atMost;
  }

  bool get isUnLimit {
    return this == SpecMode.unLimit;
  }
}

class LayoutParams {
  static final LayoutParams none = LayoutParams.matchAll();
  SizeParams width;
  SizeParams height;

  Gravity gravity;

  double weight;

  double leftMargin;
  double topMargin;
  double rightMargin;
  double bottomMargin;

  double leftPadding;
  double topPadding;
  double rightPadding;
  double bottomPadding;

  LayoutParams(
      this.width,
      this.height, {
        this.weight = -1,
        this.gravity = Gravity.leftTop,
        this.leftMargin = 0,
        this.topMargin = 0,
        this.rightMargin = 0,
        this.bottomMargin = 0,
        this.leftPadding = 0,
        this.topPadding = 0,
        this.rightPadding = 0,
        this.bottomPadding = 0,
      });

  LayoutParams.matchAll({
    this.gravity = Gravity.leftTop,
    this.weight = -1,
    this.leftMargin = 0,
    this.topMargin = 0,
    this.rightMargin = 0,
    this.bottomMargin = 0,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  })  : width = const SizeParams.match(),
        height = const SizeParams.match();

  LayoutParams.wrapAll({
    this.gravity = Gravity.leftTop,
    this.weight = 0,
    this.leftMargin = 0,
    this.topMargin = 0,
    this.rightMargin = 0,
    this.bottomMargin = 0,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  })  : width = const SizeParams.wrap(),
        height = const SizeParams.wrap();

  double get hPadding {
    return leftPadding + topPadding;
  }

  double get vPadding {
    return topPadding + bottomPadding;
  }

  double get hMargin {
    return leftMargin + rightMargin;
  }

  double get vMargin {
    return topMargin + bottomMargin;
  }
}

class SizeParams {
  static const wrapType = -2;
  static const matchType = -1;
  static const _exactly = 0;
  final SNumber size;
  final int _type;

  const SizeParams.wrap()
      : _type = wrapType,
        size = SNumber.zero;

  const SizeParams.match()
      : _type = matchType,
        size = SNumber.zero;

  SizeParams.exactly(double size)
      : _type = _exactly,
        size = SNumber.number(size);

  bool get isWrap {
    return _type == wrapType;
  }

  bool get isMatch {
    return _type == matchType;
  }

  bool get isExactly {
    return _type == _exactly;
  }

  double convert(num n) {
    if (isExactly) {
      return size.convert(n);
    }
    if (isWrap) {
      return 0;
    }
    return n.toDouble();
  }

  SpecMode toSpecMode() {
    if (_type == wrapType) {
      return SpecMode.atMost;
    }
    return SpecMode.exactly;
  }
}


