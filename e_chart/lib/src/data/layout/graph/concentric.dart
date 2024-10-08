import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'g_transform.dart';

///同心圆布局算法
class GConcentricTransform extends GTransform {
  List<SNumber> center = const [SNumber(50, true), SNumber.percent(50)];

  ///是否防止重叠
  bool preventOverlap;

  ///用于处理重叠时的迭代次数
  int maxIterations;

  ///最小节点间距
  num minNodeSpacing;

  ///最小半径间距
  num minRadiusGap;

  /// 每层环之间的距离是否相等
  bool equidistant;

  ///开始的角度
  num startAngle;

  ///扫过的角度(负数为逆时针)
  num sweepAngle;

  ///每层之间最大的间隔；用于限制和确定分层规则
  num? maxLevelDiff;

  ///权重函数
  Fun2<GraphNode, num> weightFun = (a) {
    return a.weight;
  };

  GConcentricTransform(
    super.childFun, {
    this.center = const [SNumber(50, true), SNumber.percent(50)],
    this.minNodeSpacing = 4,
    this.minRadiusGap = 20,
    this.equidistant = false,
    this.startAngle = -90,
    this.sweepAngle = 360,
    this.maxLevelDiff,
    this.preventOverlap = true,
    this.maxIterations = 360,
    Fun2<GraphNode, num>? weightFun,
    super.nodeSpaceFun,
  }) {
    if (weightFun != null) {
      this.weightFun = weightFun;
    }
  }

  Offset _center = Offset.zero;

  @override
  void transform(Context context, double width, double height, Graph? graph) {
    if (graph == null) {
      return;
    }
    _center = Offset(
      center[0].convert(width),
      center[1].convert(height),
    );
    if (graph.nodes.isEmpty) {
      return;
    }
    List<GraphNode> nodes = graph.nodes;
    int n = graph.nodes.length;
    if (n == 1) {
      nodes[0].x = _center.dx;
      nodes[0].y = _center.dy;
      notifyLayoutEnd();
      return;
    }

    ///数据分层
    List<List<GraphNode>> levelList = levelData(graph);
    List<LevelInfo> levelInfoList = [];
    num lastRadius = 0;

    ///计算每层最大半径的节点
    List<GraphNode> maxRadiusList = [];
    for (int i = 1; i < levelList.length; i++) {
      maxRadiusList.add(maxBy<GraphNode>(levelList[i], (p0) => p0.r));
    }
    num maxRadius = maxBy2<GraphNode>(maxRadiusList, (p0) => p0.r);

    ///计算每个分层的半径大小
    for (int i = 0; i < levelList.length; i++) {
      var level = levelList[i];
      LevelInfo info = LevelInfo();
      levelInfoList.add(info);
      if (i == 0) {
        info.r = level.first.r + minRadiusGap;
        lastRadius += info.r;
        continue;
      }
      if (equidistant) {
        ///等间距
        info.r = lastRadius + maxRadius + minRadiusGap;
        lastRadius = info.r + maxRadius;
      } else {
        GraphNode maxNode = maxRadiusList[i - 1];
        info.r = lastRadius + maxNode.r + minRadiusGap;
        lastRadius = info.r + maxNode.r;
      }
    }

    ///布局
    each(levelList, (level, i) {
      if (i == 0) {
        var node = level.first;
        node.x = _center.dx;
        node.y = _center.dy;
        return;
      }

      var levelInfo = levelInfoList[i - 1];
      num rr = levelInfo.r;
      num angleInterval = sweepAngle / level.length;
      num angleOffset = startAngle;

      each(level, (node, j) {
        Offset nc = circlePoint(rr, angleOffset, _center);
        if (preventOverlap && j != 0) {
          Offset pre = Offset(level[j - 1].x, level[j - 1].y);
          num sumRadius = node.r + level[j - 1].r + minNodeSpacing;
          int c = max(maxIterations, 1);
          while (nc.distance2(pre) < sumRadius && c > 0) {
            angleOffset += (sweepAngle < 0) ? -1 : 1;
            nc = circlePoint(rr, angleOffset, _center);
            c -= 1;
          }
        }
        angleOffset += angleInterval;
        node.x = nc.dx;
        node.y = nc.dy;
      });
    });
  }

  ///对数据分层
  List<List<GraphNode>> levelData(Graph graph) {
    Map<GraphNode, num> weightMap = {};
    for (var c in graph.nodes) {
      num w = weightFun.call(c);
      if (w < 0) {
        throw FlutterError('权重必须>=0');
      }
      weightMap[c] = w;
    }

    List<GraphNode> nodes = List.from(graph.nodes);
    nodes.sort((a, b) {
      return weightMap[b]!.compareTo(weightMap[a]!);
    });

    GraphNode maxWeightNode = nodes.first;
    GraphNode minWeightNode = nodes.last;
    num weightDiff = maxLevelDiff ?? -1;
    if (weightDiff <= 0) {
      weightDiff = (weightMap[maxWeightNode]! - weightMap[minWeightNode]!) / 4;
    }

    List<List<GraphNode>> rl = [];
    rl.add([nodes.removeAt(0)]);
    for (var c in nodes) {
      if (rl.length == 1) {
        rl.add([c]);
        continue;
      }
      List<GraphNode> cl = rl.last;
      num firstWeight = weightMap[cl.first]!;
      num curWeight = weightMap[c]!;
      if ((firstWeight - curWeight).abs() > weightDiff) {
        rl.add([c]);
      } else {
        cl.add(c);
      }
    }
    return rl;
  }
}

class LevelInfo {
  num r = 0;
  num angleSpace = 0;
}
