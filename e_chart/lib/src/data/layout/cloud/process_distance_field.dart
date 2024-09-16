import 'package:e_chart/e_chart.dart';

import 'helper.dart';
import 'types.dart';

Pair<List<TwoDimArray>, TwoDimArray> processImageData(
    List<List<List<num>>> dist, List<List<num>> group, WordOption options) {
  // 将输入的二维数组转为内部一位数组表现方式，优化性能
  List<TwoDimArray> newDist = [];
  for (var item in dist) {
    var array = TwoDimArray(options.width, options.height, -1);
    for (var ci in item) {
      array.set(ci[0], ci[1], ci[2]);
    }
    newDist.add(array);
  }

  var newGroup = TwoDimArray(options.width, options.height, -1);
  newGroup.fromArray(group);
  return Pair(newDist, newGroup);
}

List<Region> processDistanceField(List<TwoDimArray> dist, List<List<Point2>> contours, List<num> areas) {
  List<Region> regions = [];
  for (int i = 0; i < dist.length; i++) {
    var region = dist[i];
    var regionId = i;
    _smoothDistanceField(region);
    _smoothDistanceField(region);
    _smoothDistanceField(region);
    //查找极点，返回所有极点和最大极点
    var exr = _findExtremePointsAndMaximum(region, regionId);

    // 过滤掉极点中的最大点
    List<ExtremePoint> extremePoints =
        exr.extremePoints.takeWhile((p) => p.pos.x != exr.maxPoint.x || p.pos.y != exr.maxPoint.y).toList();

    // 过滤和处理离最大点附近的极点
    bool hasAppend = false;
    for (var i = 0; i < extremePoints.length; i++) {
      var e = extremePoints[i];
      if (extremePoints[i].pos.distance(exr.maxPoint) < 100) {
        if (i >= 1 && extremePoints[i - 1].pos.x == exr.maxPoint.x && extremePoints[i - 1].pos.y == exr.maxPoint.y) {
          extremePoints.removeRange(i, i + 1);
        } else if (e.value < exr.maxDis) {
          e.pos = exr.maxPoint;
          e.value = exr.maxDis;
        }
        hasAppend = true;
      }
    }

    if (!hasAppend) {
      var tmp = ExtremePoint(exr.maxPoint, exr.maxDis, regionId);
      tmp.pos = exr.maxPoint;
      tmp.value = exr.maxDis;
      extremePoints.add(tmp);
    }
    regions.add(Region(contours[regionId], region, extremePoints));
  }

  List<ExtremePoint> extremePoints = [];

  regions.map((region) => region.extremePoints).forEach((element) {
    extremePoints.addAll(element);
  });

  // 过滤距离较近的极点
  List<ExtremePoint> points = [];
  for (var item in extremePoints) {
    bool hasClosePoint = false;
    for (var i = 0; i < points.length; i++) {
      var p = points[i];
      if (item.pos.distance(p.pos) < 60) {
        if (p.value < item.value) {
          points[i] = item;
        }
        hasClosePoint = true;
      }
    }
    if (!hasClosePoint) {
      points.add(item);
    }
  }

  // 将过滤后的极点分配回每个region
  extremePoints = points;

  for (var i = 0; i < regions.length; i++) {
    var regionId = i;
    var region = regions[i];
    var extremePoint = extremePoints.takeWhile((value) => value.regionId == regionId).toList();
    extremePoint.sort((a, b) {
      return b.value.compareTo(a.value);
    });

    num sum = 0;
    for (var item in extremePoint) {
      sum += item.value * item.value;
    }

    for (var e in extremePoint) {
      e.ratio = roundFun((e.value * e.value) / sum, 2);
      e.value = roundFun(e.value, 2);
    }

    region.extremePoints = extremePoint;
    region.value = extremePoint[0].value;
    region.area = areas[regionId];
  }

  return regions;
}

void _smoothDistanceField(TwoDimArray dist) {
  // 平滑距离场
  const kernelSize = 3;
  var offset = (kernelSize / 2).floor();
  var [width, height] = dist.getShape();

  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      const kernel = [
        [1, 2, 1],
        [2, 4, 2],
        [1, 2, 1],
      ];
      num value = 0;
      for (var i = 0; i < kernelSize; i++) {
        for (var j = 0; j < kernelSize; j++) {
          var offsetX = i - offset;
          var offsetY = j - offset;
          value += kernel[i][j] * dist.get(x + offsetX, y + offsetY);
        }
      }
      // 此处16为kernel矩阵中值的和
      dist.set(x, y, value / 16);
    }
  }
}

// 寻找极点和最大点
ExtremeResult _findExtremePointsAndMaximum(TwoDimArray dist, int regionId) {
  List<ExtremePoint> points = [];
  num maxDis = -double.infinity;
  List<num> maxPoint = [];
  var [width, height] = dist.getShape();
  for (var y = 2; y < height - 2; y++) {
    for (var x = 2; x < width - 2; x++) {
      if (dist.get(x, y) < 0) {
        // <0 为背景
        continue;
      }

      if (dist.get(x, y) > maxDis) {
        maxDis = dist.get(x, y);
        maxPoint = [x, y];
      }

      // 极点应该比周围的点都大
      var cnt = 0;
      for (var offsetX = -1; offsetX < 2; offsetX++) {
        for (var offsetY = -1; offsetY < 2; offsetY++) {
          if (dist.get(x + offsetX, y + offsetY) < dist.get(x, y)) {
            cnt++;
          }
        }
      }

      if (cnt >= 8) {
        var ep = ExtremePoint(Point2(x, y), dist.get(x, y), regionId);
        points.add(ep);
      }
    }
  }
  return ExtremeResult(points, maxDis, Point2(maxPoint[0], maxPoint[1]));
}

class ExtremeResult {
  late List<ExtremePoint> extremePoints;
  late num maxDis;
  late Point2 maxPoint;

  ExtremeResult(this.extremePoints, this.maxDis, this.maxPoint);
}
