import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

/// 饼图
class PieView extends BasePointView<PieGeom> {
  PieView(super.context, super.series);
  double maxData = double.minPositive;
  double minData = double.maxFinite;
  double allData = 0;
  double minRadius = 0;
  double maxRadius = 0;
  double pieAngle = 0;
  int dir = 1;
  Offset center = Offset.zero;

  @override
  void onLayoutNodeStart(List<DataNode> newList) {
    num maxSize = shortSide;
    minRadius = geom.innerRadius.convert(maxSize);
    maxRadius = geom.outerRadius.convert(maxSize);
    if (maxRadius < minRadius) {
      double a = minRadius;
      minRadius = maxRadius;
      maxRadius = a;
    }
    maxData = double.minPositive;
    minData = double.maxFinite;
    allData = 0;

    pieAngle = geom.sweepAngle.abs().toDouble();
    if (pieAngle > 360) {
      pieAngle = 360;
    }
    dir = geom.sweepAngle >= 0 ? 1 : -1;
    center = viewCenter(geom.center);
    each(newList, (data, i) {
      maxData = max(data.value, maxData);
      minData = min(data.value, minData);
      allData += data.value;
    });
    if (allData == 0) {
      allData = 1;
    }
  }

  @override
  void onLayoutPositionAndSize(List<DataNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }

    if (geom.roseType == RoseType.normal) {
      _layoutForNormal(nodeList);
    } else {
      _layoutForNightingale(nodeList);
    }
    for (var node in nodeList) {
      node.extra1 = node.outRadius;
      _updateTextPosition(geom, node);
    }
  }

  @override
  void onLayoutNodeEnd(List<DataNode> nodeList) {
    for (var node in nodeList) {
      node.shape = node.buildArcShape();
    }
  }

  @override
  Attrs onBuildAnimateStarAttrs(DataNode node, DiffType type) {
    var style = geom.animatorStyle;
    var attr = node.pickArc();
    if (type == DiffType.remove || type == DiffType.update) {
      return attr;
    }
    var copy = attr.copy();
    if (style == PieAnimatorStyle.expandScale || style == PieAnimatorStyle.originExpandScale) {
      copy[Attr.outRadius] = copy[Attr.innerRadius]!;
    }
    if (style == PieAnimatorStyle.expand || style == PieAnimatorStyle.expandScale) {
      copy[Attr.startAngle] = geom.offsetAngle;
    }
    copy[Attr.sweepAngle] = 0;
    return copy;
  }

  @override
  Attrs onBuildAnimateEndAttrs(DataNode node, DiffType type) {
    var attr = node.pickArc();
    if (type == DiffType.add || type == DiffType.update) {
      return attr;
    }
    attr[Attr.sweepAngle] = 0;
    return attr;
  }

  @override
  void onAnimateLerpUpdate(DataNode node, Attrs s, Attrs e, double t, DiffType type) {
    node.fillFromAttr(s.lerp(e, t));
    node.shape = node.buildArcShape();
  }

  //普通饼图
  void _layoutForNormal(List<DataNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    int count = nodeList.length;
    num gapAllAngle = (count <= 1 ? 0 : count) * geom.angleGap.abs();
    num remainAngle = pieAngle - gapAllAngle;
    if (remainAngle <= 0) {
      remainAngle = 1;
    }
    double startAngle = geom.offsetAngle;
    double angleGap = geom.angleGap * dir;
    each(nodeList, (node, i) {
      var pieData = node;
      double sw = dir * remainAngle * pieData.value / allData;
      Offset c = center;
      double off = geom.getOffset(context, node.data);
      if (off.abs() > 1e-6) {
        c = circlePoint(off, startAngle + sw / 2, c);
      }
      node.x = c.dx;
      node.y = c.dy;
      node.inRadius = minRadius;
      node.outRadius = maxRadius;
      node.startAngle = startAngle;
      node.sweepAngle = sw;
      node.cornerRadius = geom.corner;
      node.pad = geom.angleGap;

      startAngle += sw + angleGap;
    });
  }

  // 南丁格尔玫瑰图
  void _layoutForNightingale(List<DataNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    int count = nodeList.length;
    num gapAllAngle = (count <= 1 ? 0 : count) * geom.angleGap.abs();
    num remainAngle = pieAngle - gapAllAngle;
    if (remainAngle < 0) {
      remainAngle = 1;
    }
    double startAngle = geom.offsetAngle;
    double angleGap = geom.angleGap.abs() * dir;
    if (geom.roseType == RoseType.area) {
      // 所有扇区圆心角相同，通过半径展示数据大小
      double itemAngle = dir * remainAngle / count;
      num radiusDiff = maxRadius - minRadius;

      each(nodeList, (node, i) {
        var pieData = node;
        Offset c = center;
        double off = geom.getOffset(context, node.data);
        if (off.abs() > 1e-6) {
          c = circlePoint(off, startAngle + itemAngle / 2, c);
        }
        node.x = c.dx;
        node.y = c.dy;

        node.inRadius = minRadius;
        node.outRadius = minRadius + radiusDiff * pieData.value / maxData;
        node.startAngle = startAngle;
        node.sweepAngle = itemAngle;
        node.cornerRadius = geom.corner;
        node.pad = geom.angleGap;

        startAngle += itemAngle + angleGap;
      });
    } else {
      //扇区圆心角展示数据百分比，半径表示数据大小
      each(nodeList, (node, i) {
        final pieData = node;

        double or = minRadius + (maxRadius - minRadius) * pieData.value / maxData;
        double sweepAngle = dir * remainAngle * pieData.value / allData;
        double off = geom.getOffset(context, node.data);
        Offset c = center;
        if (off.abs() > 1e-6) {
          c = circlePoint(off, startAngle + sweepAngle / 2, c);
        }
        node.x = c.dx;
        node.y = c.dy;

        node.inRadius = minRadius;
        node.outRadius = or;
        node.startAngle = startAngle;
        node.sweepAngle = sweepAngle;
        node.cornerRadius = geom.corner;
        node.pad = geom.angleGap;

        startAngle += sweepAngle + angleGap;
      });
    }
  }

  void _updateTextPosition(PieGeom series, DataNode node) {
    node.extra2 = null;
    // var labelStyle = label.style;
    // if (series.labelAlign == Align2.center) {
    //   //  label.updatePainter(offset: attr.center, align: Alignment.center);
    // } else if (series.labelAlign == Align2.end) {
    //   double radius = (node.innerRadius + node.outRadius) / 2;
    //   double angle = node.startAngle + node.sweepAngle / 2;
    //   var offset = circlePoint(radius, angle).translate(node.x, node.y);
    //   // label.updatePainter(offset: offset, align: Alignment.center);
    // } else if (series.labelAlign == Align2.start) {
    //   num expand = labelStyle.guideLine?.length ?? 0;
    //   double centerAngle = node.startAngle + node.sweepAngle / 2;
    //   Offset offset = circlePoint(node.outRadius + expand, centerAngle, node.center);
    //   Alignment align = toAlignment(centerAngle, false);
    //   if (centerAngle >= 90 && centerAngle <= 270) {
    //     align = Alignment.centerRight;
    //   } else {
    //     align = Alignment.centerLeft;
    //   }
    //   //  label.updatePainter(offset: offset, align: align);
    // } else {
    //   //  label.updatePainter(style: LabelStyle.empty);
    // }
    //
    // if (series.labelAlign == Align2.start) {
    //   Offset center = node.center;
    //   Offset tmpOffset = circlePoint(node.outRadius, node.startAngle + (node.sweepAngle / 2), center);
    //   Offset tmpOffset2 = circlePoint(
    //     node.outRadius + (labelStyle.guideLine?.length ?? 0),
    //     node.startAngle + (node.sweepAngle / 2),
    //     center,
    //   );
    //   Path path = Path();
    //   path.moveTo(tmpOffset.dx, tmpOffset.dy);
    //   path.lineTo(tmpOffset2.dx, tmpOffset2.dy);
    //   // path.lineTo(label.offset.dx, label.offset.dy);
    //   node.extra2 = path;
    // }
  }

  @override
  void onClickAfter(DataNode? now, DataNode? old) {
    List<DataNode> oldList = [];
    if (old != null) {
      oldList.add(old);
    }
    List<DataNode> newList = [];
    if (now != null) {
      newList.add(now);
    }

    const double rDiff = 8;
    DiffUtil.diffUpdate<DataNode>(
            getAnimateOption(LayoutType.update),
            oldList,
            newList,
            (node, isOld) {
              num? originR = node.extra1;
              if (originR == null) {
                originR = node.outRadius;
                node.extra1 = originR;
              }
              var attr = node.pickArc();
              if (isOld) {
                attr[Attr.outRadius] = originR.toDouble();
                return attr;
              }
              attr[Attr.outRadius] = originR + rDiff;
              return attr;
            },
            (s, e, t) => s.lerp(e, t),
            (node, map) {
              node.fillFromAttr(map);
              repaint();
            },
            () {})
        .first
        .start(context);
  }

  @override
  LayoutResult layoutSingleNode(CoordView<Coord> coord, DataNode node) {
    // TODO: implement layoutSingleNode
    throw UnimplementedError();
  }

  @override
  Size layoutSingleNodeSize(CoordView<Coord> coord, DataNode node) {
    // TODO: implement layoutSingleNodeSize
    throw UnimplementedError();
  }
}
