import 'dart:math';
import 'dart:ui';
import 'package:e_chart/e_chart.dart';

/// 旭日图布局计算(以中心点为计算中心)
class SunburstTransform extends TreeMapTransform {
  List<SNumber> center;
  List<SNumber> radius;

  ///起始角度
  double startAngle;

  ///扫过的角度 负数为逆时针
  double sweepAngle;

  ///两层半径之间的间距
  double radiusGap;

  ///相邻两扇形的角度间距
  double angleGap;

  /// 扇形圆角度数
  double corner;
  Sort sort;

  ///孩子是否占满父节点区域，如果是，那么父节点的值来源于子节点值的和
  bool matchParent;

  ///选中模式
  SelectedMode selectedMode;

  ///点击节点后的行为
  ///当为true时则点击节点后以该节点为根结点
  ///当为 false 则什么都不做
  bool rootToNode;

  ///半径差值函数
  Fun4<int, int, double, double>? radiusDiffFun;

  ///标签旋转角度函数 -1 径向旋转 -2 切向旋转  >=0 旋转角度
  Fun2<RawData, double>? rotateFun;

  ///标签对齐函数
  Fun2<RawData, Align2?>? labelAlignFun;

  ///标签间距函数
  Fun2<RawData, double>? labelMarginFun;

  SunburstTransform(
    super.parentFun,
    super.childFun, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.radius = const [SNumber.number(10), SNumber.percent(50)],
    this.startAngle = 0,
    this.sweepAngle = 360,
    this.radiusGap = 10,
    this.angleGap = 1,
    this.corner = 0,
    this.sort = Sort.none,
    this.matchParent = true,
    this.selectedMode = SelectedMode.group,
    this.rootToNode = false,
    this.labelAlignFun,
    this.labelMarginFun,
    this.radiusDiffFun,
    this.rotateFun,
  });

  ///存储布局中使用的临时量
  final SAttr _attr = SAttr();

  @override
  void transform(Context context, double width, double height, TreeNode? root) {
    _attr.center = Offset(center.first.convert(width), center.last.convert(height));
    List<double> radiusList = computeRadius(width, height);
    _attr.minRadius = radiusList[0];
    _attr.maxRadius = radiusList[1];
    double radiusRange = radiusList[2];
    if (root == null) {
      return;
    }

    Map<TreeNode, TreeNode> parentMap = {};
    var newRoot = root;
    initData2(newRoot);
    int maxDeep = newRoot.treeHeight;
    _attr.radiusDiff = radiusRange / (maxDeep <= 0 ? 1 : maxDeep);
    newRoot.shape = buildRootArc(_attr.center, maxDeep);
    updateLabelPosition(context, newRoot);
    newRoot.eachBefore((tmp, index, startNode) {
      tmp.updateStyle(context);
      var p = tmp.parent;
      if (p != null) {
        parentMap[tmp] = p;
      }
      if (tmp.hasChild) {
        _layoutChildren(context, tmp, getRadiusDiff(tmp.deep, maxDeep));
      }
      return false;
    });

    // ///执行动画
    // Map<SunburstData, Arc> arcMap = {};
    // Map<SunburstData, Arc> arcStartMap = {};
    // newRoot.each((node, index, startNode) {
    //   var arc = node.element as Arc;
    //   arcMap[node] = node.element as Arc;
    //   arcStartMap[node] = arc.copy(outRadius: arc.innerRadius);
    //   return false;
    // });
    // var lerp = ChartDoubleTween(option: animation);
    // lerp.addStartListener(() {
    //   inAnimation = true;
    //   rootNode = newRoot;
    //   showRootNode = rootNode;
    // });
    // lerp.addListener(() {
    //   var t = lerp.value;
    //   newRoot.each((node, index, startNode) {
    //     var s = arcStartMap[node]!;
    //     var e = arcMap[node]!;
    //     node.element = Arc.lerp(s, e, t);
    //     node.updateLabelPosition(context, series);
    //     return false;
    //   });
    //   notifyLayoutUpdate();
    // });
    // lerp.addEndListener(() {
    //   inAnimation = false;
    // });
    // context.addAnimationToQueue([AnimationNode(lerp, animation, type)]);
  }

  void initData2(TreeNode rootData) {
    if (sort != Sort.none) {
      rootData.sort((a, b) {
        if (sort == Sort.asc) {
          return a.value.compareTo(b.value);
        } else {
          return b.value.compareTo(a.value);
        }
      });
    }
    rootData.sum((p0) => p0.value);
    if (matchParent) {
      rootData.each((node, index, startNode) {
        if (node.hasChild) {
          node.value = 0;
        }
        return false;
      });
      rootData.sum();
    }
    rootData.computeHeight();
    rootData.setDeep(0);
    int maxDeep = rootData.treeHeight;
    rootData.each((node, index, startNode) {
      node.maxDeep = maxDeep;
      node.dataIndex = index;
      return false;
    });
  }

  void _layoutNodeIterator(Context context, TreeNode parent, int maxDeep, bool updateStyle) {
    parent.eachBefore((node, index, startNode) {
      if (updateStyle) {
        node.updateStyle(context);
      }
      if (node.hasChild) {
        _layoutChildren(context, node, getRadiusDiff(node.deep, maxDeep));
      }
      return false;
    });
  }

  void _layoutChildren(Context context, TreeNode parent, num radiusDiff) {
    if (parent.childCount == 0) {
      return;
    }
    final corner = this.corner.abs();
    final angleGap = this.angleGap.abs();
    final radiusGap = this.radiusGap.abs();
    final Arc parentArc = parent.shape as Arc;
    if (parent.childCount == 1) {
      var ir = parentArc.outRadius + radiusGap;
      parent.firstChild.shape = parentArc.copy(
        innerRadius: ir,
        outRadius: ir + radiusDiff,
        maxRadius: _attr.maxRadius,
      );
      updateLabelPosition(context, parent.firstChild);
      return;
    }

    bool match = matchParent;
    if (!match) {
      num childAllValue = sumBy<TreeNode>(parent.children, (p0) => p0.value);
      match = childAllValue >= parent.value;
    }
    int gapCount = parent.childCount - 1;
    if (match) {
      gapCount = parent.childCount;
      if (parent.parent != null) {
        gapCount -= 1;
        // if (parent.parent is SunburstVirtualNode) {
        //   gapCount += 1;
        // }
      }
    }

    final int dir = sweepAngle < 0 ? -1 : 1;
    final double remainAngle = parentArc.sweepAngle.abs() - angleGap * gapCount;

    double childStartAngle = parentArc.startAngle;

    if (match && (parent.parent == null)) {
      childStartAngle += dir * angleGap / 2;
    }

    final double ir = parentArc.outRadius + radiusGap;
    final double or = ir + radiusDiff;

    each(parent.children, (ele, i) {
      double percent = ele.value / parent.value;
      if (percent > 1) {
        throw ChartError("内部异常");
      }
      double swa = remainAngle * percent;
      ele.shape = Arc(
          innerRadius: ir,
          outRadius: or,
          startAngle: childStartAngle,
          sweepAngle: swa * dir,
          cornerRadius: corner,
          padAngle: angleGap,
          maxRadius: _attr.maxRadius,
          center: _attr.center);
      updateLabelPosition(context, ele);
      childStartAngle += (swa + angleGap) * dir;
    });
  }

  ///构建根节点布局位置
  Arc buildRootArc(Offset center, int maxDeep) {
    double diff = _attr.radiusDiff;
    var fun = radiusDiffFun;
    if (fun != null) {
      diff = fun.call(0, maxDeep, _attr.radiusDiff);
    }
    double or = _attr.minRadius + diff;
    return Arc(
      innerRadius: 0,
      outRadius: or,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      center: center,
      maxRadius: _attr.maxRadius,
    );
  }

  ///构建返回节点布局属性
  Arc buildBackArc(Offset center, int deepDiff) {
    double or = _attr.minRadius;
    if (or <= 0) {
      or = getRadiusDiff(0, deepDiff);
    }
    return Arc(
      innerRadius: 0,
      outRadius: or,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      center: center,
      maxRadius: _attr.maxRadius,
    );
  }

  List<double> computeRadius(double width, double height) {
    double size = min(width, height);
    double minRadius = 0;
    double maxRadius = 0;
    List<SNumber> radius = this.radius;
    if (radius.isEmpty) {
      maxRadius = const SNumber.percent(50).convert(size);
    } else if (radius.length == 1) {
      maxRadius = radius[0].convert(size);
    } else {
      minRadius = radius[0].convert(size);
      maxRadius = radius.last.convert(size);
    }
    if (minRadius < 0) {
      minRadius = 0;
    }
    if (maxRadius < 0) {
      maxRadius = 0;
    }
    if (maxRadius < minRadius) {
      double v = maxRadius;
      maxRadius = minRadius;
      minRadius = v;
    }
    if (maxRadius <= 0) {
      maxRadius = const SNumber.percent(50).convert(size);
    }
    return [minRadius, maxRadius, maxRadius - minRadius];
  }

  // void _forward(SunburstData clickNode) {
  //   var oldBackNode = showRootNode;
  //   var hasBack = showRootNode is SunburstVirtualNode;
  //   var animation = getAnimation(LayoutType.update, -1);
  //   if (hasBack && oldBackNode != null) {
  //     oldBackNode.clear();
  //     clickNode.parent = null;
  //     oldBackNode.add(clickNode);
  //     oldBackNode.value = clickNode.value;
  //
  //     var oldE = oldBackNode.element as Arc;
  //     var s = clickNode.element as Arc;
  //     var ir = oldE.outRadius + series.radiusGap;
  //     var e = Arc(
  //       innerRadius: ir,
  //       outRadius: ir + getRadiusDiff(1, clickNode.height + 1),
  //       center: center,
  //       startAngle: series.startAngle,
  //       sweepAngle: series.sweepAngle,
  //       maxRadius: maxRadius,
  //     );
  //     if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
  //       clickNode.element = e;
  //       clickNode.updateLabelPosition(context, series);
  //       _layoutNodeIterator(clickNode, clickNode.height + 1, false);
  //       notifyLayoutUpdate();
  //       return;
  //     }
  //
  //     var lerp = ChartDoubleTween(option: animation);
  //     lerp.addListener(() {
  //       var t = lerp.value;
  //       clickNode.element = Arc.lerp(s, e, t);
  //       clickNode.updateLabelPosition(context, series);
  //       _layoutNodeIterator(clickNode, clickNode.height + 1, false);
  //       notifyLayoutUpdate();
  //     });
  //     lerp.start(context, true);
  //     return;
  //   }
  //
  //   ///拆分动画
  //   ///返回节点
  //   var be = buildBackArc(center, clickNode.height + 1);
  //   var bs = be.copy(outRadius: be.innerRadius);
  //   var bn = SunburstVirtualNode(clickNode, bs);
  //
  //   var cs = clickNode.element as Arc;
  //   var ir = be.outRadius + series.radiusGap;
  //   var ce = Arc(
  //     startAngle: series.startAngle,
  //     sweepAngle: series.sweepAngle,
  //     innerRadius: ir,
  //     outRadius: ir + getRadiusDiff(1, clickNode.height + 1),
  //     center: center,
  //     maxRadius: maxRadius,
  //   );
  //   if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
  //     bn.element = be;
  //     bn.updateLabelPosition(context, series);
  //     clickNode.element = ce;
  //     clickNode.updateLabelPosition(context, series);
  //     _layoutNodeIterator(clickNode, clickNode.height + 1, false);
  //     showRootNode = bn;
  //     notifyLayoutUpdate();
  //     return;
  //   }
  //
  //   var lerp = ChartDoubleTween(option: animation);
  //   lerp.addListener(() {
  //     var t = lerp.value;
  //     bn.element = Arc.lerp(bs, be, t);
  //     bn.updateLabelPosition(context, series);
  //
  //     clickNode.element = Arc.lerp(cs, ce, t);
  //     clickNode.updateLabelPosition(context, series);
  //     _layoutNodeIterator(clickNode, clickNode.height + 1, false);
  //     notifyLayoutUpdate();
  //   });
  //   showRootNode = bn;
  //   lerp.start(context, true);
  // }
  //
  // void back() {
  //   var bn = showRootNode;
  //   showRootNode = null;
  //   if (bn == null || bn is! SunburstVirtualNode) {
  //     return;
  //   }
  //   var first = bn.firstChild;
  //   first.parent = null;
  //
  //   Map<SunburstData, Arc> oldArcMap = {};
  //   first.each((node, index, startNode) {
  //     oldArcMap[node] = node.element as Arc;
  //     return false;
  //   });
  //
  //   var parentData = first.parent?.parent;
  //   SunburstData parentNode;
  //   if (parentData == null) {
  //     parentNode = rootNode!;
  //     bn = rootNode!;
  //     first.parent = bn;
  //   } else {
  //     parentData = first.parent!;
  //     parentNode = parentData.parent!;
  //     parentNode.parent = null;
  //     bn = SunburstVirtualNode(parentNode, buildBackArc(center, parentNode.height + 1));
  //   }
  //   bn.updateLabelPosition(context, series);
  //   _layoutNodeIterator(bn, parentNode.height + 1, false);
  //
  //   var animation = getAnimation(LayoutType.update, -1);
  //   if (animation == null) {
  //     showRootNode = bn;
  //     notifyLayoutUpdate();
  //     return;
  //   }
  //
  //   Map<SunburstData, Arc> arcMap = {};
  //   parentNode.each((node, index, startNode) {
  //     var arc = node.element as Arc;
  //     arcMap[node] = arc;
  //     if (!oldArcMap.containsKey(node)) {
  //       oldArcMap[node] = arc.copy(outRadius: arc.innerRadius, maxRadius: maxRadius);
  //     }
  //     return false;
  //   });
  //   var lerp = ChartDoubleTween(option: animation);
  //   lerp.addListener(() {
  //     var t = lerp.value;
  //     parentNode.each((node, index, startNode) {
  //       var e = arcMap[node]!;
  //       var s = oldArcMap[node]!;
  //       node.element = Arc.lerp(s, e, t);
  //       node.updateLabelPosition(context, series);
  //       return false;
  //     });
  //     notifyLayoutUpdate();
  //   });
  //   lerp.start(context, true);
  //   showRootNode = bn;
  // }
  // void onHandleHoverAndClick(Offset offset, bool click) {
  //   var sn = showRootNode;
  //   if (sn == null) {
  //     return;
  //   }
  //   var hoverNode = findData(offset);
  //   var oldNode = oldHoverData;
  //   oldHoverData = hoverNode;
  //   if (hoverNode == oldNode) {
  //     if (hoverNode != null && hoverNode is! SunburstVirtualNode) {
  //       //   sendHoverEvent(offset, hoverNode);
  //     }
  //     return;
  //   }
  //   List<NodeDiff<SunburstData>> nl = [];
  //   if (oldNode != null) {
  //     var attr = oldNode.toAttr();
  //     oldNode.removeState(ViewState.hover);
  //     oldNode.updateStyle(context, series);
  //     nl.add(NodeDiff(oldNode, attr, oldNode.toAttr(), true));
  //     if (oldNode is! SunburstVirtualNode) {
  //       sendHoverEndEvent(oldNode);
  //     }
  //   }
  //   if (hoverNode != null) {
  //     var attr = hoverNode.toAttr();
  //     hoverNode.addState(ViewState.hover);
  //     hoverNode.updateStyle(context, series);
  //     nl.add(NodeDiff(hoverNode, attr, hoverNode.toAttr(), false));
  //     if (hoverNode is! SunburstVirtualNode) {
  //       sendHoverEvent(offset, hoverNode);
  //     }
  //   }
  //   var animation = getAnimation(LayoutType.update, getAnimatorCountLimit());
  //   if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
  //     notifyLayoutUpdate();
  //     return;
  //   }
  //   onRunUpdateAnimation(nl, animation);
  // }

  double getRadiusDiff(int deep, int maxDeep) {
    double rd = _attr.radiusDiff;
    if (radiusDiffFun != null) {
      rd = radiusDiffFun!.call(deep, maxDeep, rd);
    }
    return rd;
  }

  @override
  int get showDepth => 1;

  void updateLabelPosition(Context context, TreeNode hierarchy) {
    // label.updatePainter();
    // if (label.notDraw) {
    //   return;
    // }
    // var arc = element as Arc;
    // label.updatePainter();
    // Size size = label.getSize();
    // double labelMargin = series.labelMarginFun?.call(this) ?? 0;
    // if (labelMargin > 0) {
    //   size = Size(size.width + labelMargin, size.height);
    // }
    //
    // var originAngle = arc.startAngle + arc.sweepAngle / 2;
    //
    // var dx = m.cos(originAngle * StaticConfig.angleUnit) * (arc.innerRadius + arc.outRadius) / 2;
    // var dy = m.sin(originAngle * StaticConfig.angleUnit) * (arc.innerRadius + arc.outRadius) / 2;
    // var align = series.labelAlignFun?.call(this) ?? Align2.start;
    // if (align == Align2.start) {
    //   dx = m.cos(originAngle * StaticConfig.angleUnit) * (arc.innerRadius + size.width / 2);
    //   dy = m.sin(originAngle * StaticConfig.angleUnit) * (arc.innerRadius + size.width / 2);
    // } else if (align == Align2.end) {
    //   dx = m.cos(originAngle * StaticConfig.angleUnit) * (arc.outRadius - size.width / 2);
    //   dy = m.sin(originAngle * StaticConfig.angleUnit) * (arc.outRadius - size.width / 2);
    // }
    // var textPosition = Offset(dx, dy).translate2(arc.center);
    // double rotateMode = series.rotateFun?.call(this) ?? -1;
    // double rotateAngle = 0;
    //
    // if (rotateMode <= -2) {
    //   ///切向
    //   if (originAngle >= 360) {
    //     originAngle = originAngle % 360;
    //   }
    //   if (originAngle >= 0 && originAngle < 90) {
    //     rotateAngle = originAngle % 90;
    //   } else if (originAngle >= 90 && originAngle < 270) {
    //     rotateAngle = originAngle - 180;
    //   } else {
    //     rotateAngle = originAngle - 360;
    //   }
    // } else if (rotateMode <= -1) {
    //   ///径向
    //   if (originAngle >= 360) {
    //     originAngle = originAngle % 360;
    //   }
    //   if (originAngle >= 0 && originAngle < 180) {
    //     rotateAngle = originAngle - 90;
    //   } else {
    //     rotateAngle = originAngle - 270;
    //   }
    // } else if (rotateMode > 0) {
    //   rotateAngle = rotateMode;
    // }
    //
    // label.updatePainter(
    //   rotate: rotateAngle,
    //   offset: textPosition,
    //   align: Alignment.center,
    // );
  }
}

class SAttr {
  Offset center = Offset.zero;
  double minRadius = 0;
  double maxRadius = 0;
  double radiusDiff = 0;
}
