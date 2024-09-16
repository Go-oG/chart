import 'dart:math';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/data/layout/cloud/spiral.dart';

import 'helper.dart';
import 'types.dart';

/// 生成思想为将每个region内每个极点的单词随机放置在极点附近
/// 然后对每个单词以极点为中心，当前位置为初始位置，使用螺旋线进行排布
/// 注意 word的坐标原点为单词中心, box的原点是左下角
void generateWordle(List<Keyword> words, List<Region> regions, TwoDimArray group, WordOption option) {
  List<Point2> deepCopyPosition() {
    return List.from(words.map((e) => e.position ?? Point2(0, 0)));
  }

  for (var word in words) {
    createWordBox(word, option);
  }
  List<Point2> prePosition = [];
  for (var regionID = 0; regionID < regions.length; regionID++) {
    var region = regions[regionID];
    bool success = true;
    for (var count = 0; count < 1; count++) {
      var wordle = WordState([], false);
      for (var i = 0; i < words.length; i++) {
        var word = words[i];
        if (word.regionID == regionID) {
          randomPlaceWord(word, region.extremePoints[word.epID!], regionID, group);
          wordle = wordleAlgorithm(wordle.drawnWords, word, regionID, regions, group, option);
          if (wordle.state == false) {
            success = false;
            break;
          }
        }
      }

      if (!success) {
        //如果cont为0，则该分区在进行第一遍循环时就有单词溢出了
        //此种情况下需要调整字号,重新分配
        if (count == 0 && option.maxFontSize >= 10) {
          regionID = -1;
          option.maxFontSize--;
          for (var word in words) {
            createWordBox(word, option);
          }
        } else {
          for (int i = 0; i < words.length; i++) {
            words[i].position = prePosition[i];
          }
          break;
        }
      } else {
        prePosition = deepCopyPosition();
      }
      break;
    }
  }
}

void createWordBox(Keyword word, WordOption options) {
  // 设置每个单词整体的box和每个字母的box
  var minFontSize = options.minFontSize;
  var maxFontSize = options.maxFontSize;

  var fontSize = ((maxFontSize - minFontSize) * sqrt(word.weight) + minFontSize).round();
  var size = measureTextSize(word.name, fontSize, word.fontWeight, word.fontFamily);
  var width = size.width;
  var height = size.height;
  var descent = size.descent;
  var ascent = size.ascent;

  word.box = [];
  word.fontSize = fontSize;
  word.width = width;
  word.height = height;
  word.descent = descent;
  word.ascent = ascent;
  word.gap = 2;

  word.box!.add(BBox(0, descent + word.gap, width, height + 2 * word.gap));

  // 对于权重大于0.5的, 对每个字母建立box
  if (word.weight > 0.3) {
    num x = 0;
    for (var i = 0; i < word.name.length; i++) {
      var size2 = measureTextSize(word.name[i], fontSize, word.fontWeight, word.fontFamily);
      if (size2.ascent > 0) {
        // 处理类似中文’一‘的情况, 暂时这样
        size2.width = size2.ascent * 2;
        size2.descent = 2;
      }
      word.box!.add(BBox(x, descent + word.gap, size2.width, size2.height + 2 * word.gap));
      x += size2.width;
    }
  }
}

void randomPlaceWord(Keyword word, ExtremePoint center, num regionID, TwoDimArray group) {
// 在regionID的center附近随机放置单词
  num range = word.weight > 0.8 ? center.value / 5 : center.value / 3;

  var xmax = center.pos.x + range, xmin = center.pos.x - range;
  var ymax = center.pos.y + range, ymin = center.pos.y - range;

  num x, y;
  do {
    x = (random() * (xmax - xmin + 1) + xmin).round();
    y = (random() * (ymax - ymin + 1) + ymin).round();
  } while (group.get(x, y) - 1 != regionID);

  word.position = Point2(x, y);
}

WordState wordleAlgorithm(
    List<Keyword> drawnWords, Keyword word, int regionID, List<Region> regions, TwoDimArray group, WordOption options) {
// 确定word的位置
// drawnWords存放已经确定位置的单词
  var width = options.width;
  var height = options.height;
  var extremePoints = regions[regionID].extremePoints;
  var dist = regions[regionID].dist;

  var count = 0;
  Keyword? lastOverlapItem;
  do {
    count++;
    // 螺旋线的起点是极点的中心
    var startPoint = extremePoints[word.epID!].pos;
    var newPoint = iterate(dist, startPoint, word.position!, width, height);
    if (newPoint != null) {
      word.position = Point2(newPoint.x, newPoint.y);
    } else {
      continue;
    }

// 先检测与上次有overlap的单词，现在是否还是overlap，有overlap则失败
    if (lastOverlapItem != null && isOverlap(lastOverlapItem, word)) continue;

// 不在shapewordle内部，则失败
    if (!isInShape(word, options, group, regionID, regions)) continue;
    bool foundOverlap = false;
    for (var drawnWord in drawnWords) {
      if (isOverlap(drawnWord, word)) {
        // 发现碰撞，则传入碰撞的单词
        foundOverlap = true;
        lastOverlapItem = drawnWord;
        break;
      }
    }

    if (!foundOverlap) {
// 没发现overlap，则传入到drawnWords中，放置成功
      drawnWords.add(word);
      word.state = true;
      return WordState(drawnWords, true);
    }
  } while (count < 12000);

  return WordState(drawnWords, false);
}

class WordState {
  bool state = false;
  List<Keyword> drawnWords = [];

  WordState(this.drawnWords, this.state);
}

bool isOverlap(Keyword word1, Keyword word2) {
// 对单词进行的overlap碰撞检测
  List<List<List<num>>> getWordPoint(Keyword word) {
    List<List<List<num>>> points = []; // 子数组格式为[left top, right top, right bottom, left bottom]
    var wordPos = word.position;
    var angle = word.angle;
    var width = word.width;
    var height = word.height;

    for (var box in word.box!) {
      var boxWidth = box.width;
      var boxHeight = box.height;
      var boxPos = [box.left + wordPos!.x - width! / 2, box.top + wordPos.y + height! / 2];

      points.add([
        [boxPos[0], boxPos[1] - boxHeight],
        [boxPos[0] + boxWidth, boxPos[1] - boxHeight],
        [boxPos[0] + boxWidth, boxPos[1]],
        [boxPos[0], boxPos[1]],
      ]);
    }

    if (angle != 0) {
      return points.map((point) {
        return point
            .map((p) => [
                  (p[0] - wordPos!.x) * cos(angle!) - (p[1] - wordPos.y) * sin(angle) + wordPos.x,
                  (p[0] - wordPos.x) * sin(angle) + (p[1] - wordPos.y) * cos(angle) + wordPos.y,
                ])
            .toList();
      }).toList();
    }
    return points;
  }

  bool isIntersectedPolygons(List<List<num>> a, List<List<num>> b) {
    var polygons = [a, b];
    for (var i = 0; i < polygons.length; i++) {
      var polygon = polygons[i];
      for (var j = 0; j < polygons.length; j++) {
        var p1 = polygon[j];
        var p2 = polygon[(j + 1) % polygon.length];

        var normal = [p2[1] - p1[1], p1[0] - p2[0]];

        var projectedA = a.map((p) => normal[0] * p[0] + normal[1] * p[1]);
        var minA = min2(projectedA);
        var maxA = max2(projectedA);

        var projectedB = b.map((p) => normal[0] * p[0] + normal[1] * p[1]);
        var minB = min2(projectedB);
        var maxB = max2(projectedB);

        if (maxA < minB || maxB < minA) {
          return false;
        }
      }
    }
    return true;
  }

  var p1 = getWordPoint(word1);
  var p2 = getWordPoint(word2);
  for (var i = 0; i < p1.length; i++) {
    for (var j = 0; j < p2.length; j++) {
      var a = p1[i], b = p2[j];
      return isIntersectedPolygons(a, b);
    }
  }
  return false;
}

bool isInShape(Keyword word, WordOption options, TwoDimArray group, int regionID, List<Region> regions) {
  var canvasWidth = options.width;
  var canvasHeight = options.height;

// 判断是否在shapewordle内
  var p = getCornerPoints(word);
  if (!(isPointInShape(p[0], canvasWidth, canvasHeight, group, regionID) &&
      isPointInShape(p[1], canvasWidth, canvasHeight, group, regionID) &&
      isPointInShape(p[2], canvasWidth, canvasHeight, group, regionID) &&
      isPointInShape(p[3], canvasWidth, canvasHeight, group, regionID))) {
    return false;
  }

  for (var region in regions) {
    var contour = region.contour;
    if (isIntersected(contour, p[0], p[1]) ||
        isIntersected(contour, p[1], p[2]) ||
        isIntersected(contour, p[2], p[3]) ||
        isIntersected(contour, p[3], p[0])) {
      return false;
    }
  }
  return true;
}

List<Point2> getCornerPoints(Keyword word) {
// 获得单词四个角的坐标
  var pos = word.position;
  var angle = word.angle;
  var width = word.width;
  var height = word.height;

  var pl = [
    Point2(pos!.x - width! / 2, pos.y - height! / 2), // left top
    Point2(pos.x + width / 2, pos.y - height / 2), // right top
    Point2(pos.x + width / 2, pos.y + height / 2), // right bottom
    Point2(pos.x - width / 2, pos.y + height / 2), // left bottom
  ];
  if (angle != 0) {
    return pl
        .map((p) => Point2(
              (p.x - pos.x) * cos(angle!) - (p.y - pos.y) * sin(angle) + pos.x,
              (p.x - pos.x) * sin(angle) + (p.y - pos.y) * cos(angle) + pos.y,
            ))
        .toList();
  }
  return pl;
}

bool isPointInShape(Point2 point, num canvasWidth, num canvasHeight, TwoDimArray group, int regionID) {
// 判断点是否在shape内，且是否在对应的region内
  var x = point.x.floor();
  var y = point.y.floor();

  if (x >= 0 && y >= 0 && x < canvasWidth && y < canvasHeight) {
    return group.get(x, y) - 1 == regionID;
  } else {
    return false;
  }
}

bool isIntersected(List<Point2> contour, Point2 p1, Point2 p2) {
  num crossMul(Point2 a, Point2 b, Point2 c) {
    return (a.x - c.x) * (b.y - c.y) - (b.x - c.x) * (a.y - c.y);
  }

//检测线段是否和边界相交
  bool isLineIntersected(Point2 aa, Point2 bb, Point2 cc, Point2 dd) {
//检测两个线段是否相交的方法
    if (max(aa.x, bb.x) < min(cc.x, dd.x)) {
      return false;
    }
    if (max(aa.y, bb.y) < min(cc.y, dd.y)) {
      return false;
    }
    if (max(cc.x, dd.x) < min(aa.x, bb.x)) {
      return false;
    }
    if (max(cc.y, dd.y) < min(aa.y, bb.y)) {
      return false;
    }
    if (crossMul(cc, bb, aa) * crossMul(bb, dd, aa) < 0) {
      return false;
    }
    if (crossMul(aa, dd, cc) * crossMul(dd, bb, cc) < 0) {
      return false;
    }
    return true;
  }

  bool intersected = false;
  for (var i = 0; i < contour.length - 1; i++) {
    intersected = isLineIntersected(p1, p2, contour[i], contour[i + 1]);
    if (intersected) break;
  }

  if (intersected) {
    return true;
  } else {
    return isLineIntersected(p1, p2, contour[contour.length - 1], contour[0]);
  }
}
