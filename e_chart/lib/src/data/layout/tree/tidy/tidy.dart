import 'dart:ui';

import 'package:e_chart/src/component/tree.dart';
import 'package:e_chart/src/core/context.dart';
import 'package:e_chart/src/data/index.dart';
import 'layout/basic_layout.dart';
import 'layout/tidy_layout.dart';

enum TidyLayoutType {
  basic,
  tidy,
  layeredTidy,
}

class TTidyTreeTransform extends TreeTransform {
  TidyLayoutType layoutType;
  late TidyBasicLayout _layout;

  TTidyTreeTransform(
    super.parentFun,
    super.childFun, {
    this.layoutType = TidyLayoutType.tidy,
    super.center,
    super.levelGapSize = 36,
    super.lineType,
    super.nodeGapSize = const Offset(8, 8),
    super.rootInCenter,
    super.smooth,
  }) : super(levelGapFun: null, gapFun: null) {
    if (layoutType == TidyLayoutType.basic) {
      _layout = TidyBasicLayout(parentChildMargin: levelGapSize!, peerMargin: nodeGapSize!.dx);
    } else if (layoutType == TidyLayoutType.layeredTidy) {
      _layout = TidyLayout.ofLayered(levelGapSize!, nodeGapSize!.dx);
    } else {
      _layout = TidyLayout(parentChildMargin: levelGapSize!, peerMargin: nodeGapSize!.dx);
    }
  }

  void changeLayout(TidyLayoutType layoutType) {
    if (layoutType == this.layoutType) {
      return;
    }
    var parentChildMargin = _layout.parentChildMargin;
    var peerMargin = _layout.peerMargin;
    switch (layoutType) {
      case TidyLayoutType.basic:
        _layout = TidyBasicLayout(parentChildMargin: parentChildMargin, peerMargin: peerMargin);
        break;
      case TidyLayoutType.tidy:
        _layout = TidyLayout(parentChildMargin: parentChildMargin, peerMargin: peerMargin);
        break;
      case TidyLayoutType.layeredTidy:
        _layout = TidyLayout.ofLayered(parentChildMargin, peerMargin);
        break;
    }

    this.layoutType = layoutType;
  }

  void doLayoutNode() {}

  @override
  void transform2(Context context, double width, double height, TreeNode root) {
    _layout.layout(root);
  }
}
