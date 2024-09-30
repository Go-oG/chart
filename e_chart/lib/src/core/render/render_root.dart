import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/chart_scope.dart';
import 'package:e_chart/src/core/widget_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/widgets.dart';

///该类负责将Flutter原生的布局、渲染流程映射到我们的ChartRender中
final class RenderRoot extends RenderBox implements ViewParent {
  ChartOption option;
  TickerProvider provider;
  WidgetBridge widgetAdapter;

  final Paint _paint = Paint();
  late final AttachInfo attachInfo;
  BoxConstraints? oldConstraints;

  Rect bound = Rect.zero;

  Context? _context;

  bool _inDrawing = false;

  bool _needRepaint = false;

  RenderRoot(
    this.option,
    this.provider,
    this.widgetAdapter,
  ) {
    attachInfo = AttachInfo(this);
    var dp = WidgetsBinding.instance.platformDispatcher.displays.first.devicePixelRatio;
    _context =chartScope.getOrCreateContext(option, provider, dp);
    _context?.tooltipNotifier.addListener((v) {
      widgetAdapter.toolTipNotifier.value = v;
    });
    _initRender(option, provider);
  }

  void _initRender(ChartOption option, TickerProvider provider) {
    var rootView = _context?.viewManager.rootView;
    rootView?.dispatchAttachInfo(attachInfo);
    rootView?.parent = this;
    rootView?.created();
  }

  void onUpdateRender(ChartOption option, TickerProvider provider) {
    bool change = false;
    if (option != this.option) {
      this.option = option;
      change = true;
    }
    Logger.i('onUpdateRender');
    this.provider = provider;
    _context?.tickerProvider = provider;
    attachInfo.root = this;
    markNeedsCompositingBitsUpdate();
    markNeedsSemanticsUpdate();
    if (!hasSize || change) {
      markNeedsLayout();
    } else {
      markNeedsPaint();
    }
  }

  ///======================父类方法=====================

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _context?.attach();
    _context?.gestureDispatcher.enable();
  }

  @override
  void detach() {
    _context?.detach();
    _context?.gestureDispatcher.disable();
    super.detach();
  }

  @override
  void performResize() {
    oldConstraints = constraints;
    double minW = constraints.minWidth;
    double minH = constraints.minHeight;
    double maxW = constraints.maxWidth;
    double maxH = constraints.maxHeight;
    double w = adjustSize(maxW, minW);
    double h = adjustSize(maxH, minH);
    size = Size(w, h);
  }

  double adjustSize(double maxSize, double minSize) {
    if (maxSize.isFinite && maxSize > 0) {
      return maxSize;
    }
    if (minSize.isFinite && minSize > 0) {
      return minSize;
    }
    throw ChartError("size constraints is NaN Or Infinite and defaultSize is Null");
  }

  @override
  void performLayout() {
    super.performLayout();
    double w = size.width;
    double h = size.height;
    measure(w, h);
    _context?.viewManager.rootView?.layout(0, 0, w, h);
  }

  void measure(double parentWidth, double parentHeight) {
    _context?.animateManager.cancelAllAnimator();
    var widthSpec = MeasureSpec.exactly(parentWidth);
    var heightSpec = MeasureSpec.exactly(parentHeight);
    _context?.viewManager.rootView?.measure(widthSpec, heightSpec);
    bound = Rect.fromLTWH(0, 0, parentWidth, parentHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _needRepaint = false;
    _inDrawing = true;
    _context?.dispatchEvent(RenderedEvent.rendered);

    var cc = Canvas2.fromContext(context);
    var bc = _context?.option.theme.backgroundColor;
    if (bc != null) {
      _paint.reset();
      _paint.color = bc;
      _paint.style = PaintingStyle.fill;
      cc.drawRect(bound, _paint);
    }

    _context?.viewManager.rootView?.draw(cc);
    _inDrawing = false;

    if (_needRepaint) {
      _needRepaint = false;
      requestDraw();
    } else {
      ///推迟动画到最后
      var queue = _context?.getAndResetAnimateQueue();
      var tc = _context;
      if (tc != null && queue != null) {
        for (var node in queue) {
          node.start(tc);
        }
      }
    }
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    _context?.gestureDispatcher.processPointEvent(event, entry);
  }

  ///================自定义接口方法开始=============
  void requestDraw() {
    if (_inDrawing) {
      _needRepaint = true;
      return;
    }
    markNeedsSemanticsUpdate();
    markNeedsPaint();
  }

  @override
  void requestLayout() {
    markNeedsSemanticsUpdate();
    markNeedsLayout();
  }

  @override
  void changeChildToFront(ChartView child) {}

  @override
  void childHasTransientStateChanged(ChartView child, bool hasTransientState) {}

  @override
  bool getChildVisibleRect(ChartView child, Rect r, Offset offset) {
    return r.overlaps(bound);
  }

  @override
  bool isLayoutRequested() => true;

  @override
  void onDescendantInvalidated(ChartView child, ChartView target) {
    markNeedsPaint();
  }

  @override
  void recomputeViewAttributes(ChartView child) {}

  @override
  void requestChildFocus(ChartView child, ChartView focused) {
    markNeedsPaint();
  }

  @override
  void redrawParentCaches() {}

  @override
  void childVisibilityChange(ChartView child, ViewVisibility old) {}

  @override
  void clearChildFocus(ChartView child) {
    requestDraw();
  }

  @override
  void clearFocus() {
    requestDraw();
  }

  @override
  void unFocus(ChartView focused) {
    requestDraw();
  }

  @override
  bool get isRepaintBoundary => true;

  ///指定其大小由父容器确定
  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void dispose() {
    _context?.dispatchEvent(ChartDisposeEvent.single);
    _context?.dispose();
    _context = null;
    super.dispose();
  }
}
