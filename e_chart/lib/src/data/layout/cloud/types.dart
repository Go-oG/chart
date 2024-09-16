import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/index.dart';

import 'helper.dart';

class WordOption {
  final int width;
  final int height;

// 是否进行词性还原
  final bool lemmatization;

  // keyword 数量
  final int keywordsNum;

  // 角度模式，0-全横，1-横竖，2-random，3-45度向上\\，4-45度向下//，5-45度向上以及向下/\\/
  final int angleMode;

  // 分配单词到region时根据面积还是根据distance value
  final bool baseOnArea;

  // true之后，会不考虑数据的真实度，尽可能放大单词以填充区域
  final bool isMaxMode;

  num maxFontSize;
  final num minFontSize;
  final num fillFontSize;
  final String? fontFamily;
  final FontWeight fontWeight;
  final num resizeFactor;
  final num eps;

  WordOption(
    this.width,
    this.height,
    this.keywordsNum, {
    this.lemmatization = true,
    this.angleMode = 2,
    this.baseOnArea = true,
    this.isMaxMode = true,
    this.maxFontSize = 45,
    this.minFontSize = 9,
    this.fillFontSize = 15,
    this.fontWeight = FontWeight.normal,
    this.resizeFactor = 4,
    this.eps = 0.0000001,
    this.fontFamily,
  });
}

///极值点
class ExtremePoint {
  Point2 pos;
  num value;
  int regionId;

  ExtremePoint(this.pos, this.value, this.regionId);

  num? ratio;
  num? epWeight;
  num? epNumber;
}

class Region {
  List<Point2> contour;
  TwoDimArray dist;
  List<ExtremePoint> extremePoints;

  Region(this.contour, this.dist, this.extremePoints);

  num? value;
  num? area;
  num? wordsNum;
  num? wordsWeight;
}

class Keyword {
  String name;
  num weight;
  String? fontFamily;
  FontWeight fontWeight;

  Keyword(this.name, this.weight, this.fontFamily, this.fontWeight);

  late num fontSize;
  num? angle;
  Point2? position;
  num? regionID;
  int? epID;
  List<BBox>? box;
  num? width;
  num? height;
  num? ascent;
  num? descent;
  num gap = 0;
  bool? state;
}

class RenderKeyWord {
  String name;
  num x;
  num y;
  num drawX;
  num drawY;
  num fontSize;
  String? fontFamily;
  FontWeight fontWeight;
  num angle;

  RenderKeyWord(
    this.name,
    this.x,
    this.y,
    this.drawX,
    this.drawY,
    this.fontSize,
    this.fontFamily,
    this.fontWeight,
    this.angle,
  );
}

class FillWord {
  String name;
  num weight;
  String? fontFamily;
  FontWeight fontWeight;

  FillWord(this.name, this.weight, this.fontFamily, this.fontWeight);
}

class RenderFillWord {
  late String name;

  late num fontSize;
  late String? fontFamily;
  late FontWeight fontWeight;
  late num angle;
  late num alpha;
  late num x;
  late num y;
  RenderFillWord(
    this.name,
    this.fontSize,
    this.fontFamily,
    this.fontWeight,
    this.angle,
    this.alpha,
  );
}

class Word {
  String name;
  num weight;

  Word(this.name, this.weight);
}

class FillSetting {
  late num canvasWidth;
  late num canvasHeight;
  late num gridSize;

  // 每个grid的边长，建议为1，更大边长会加快filling速度，但会导致overlap
  late int gridWidth;
  late int gridHeight;

  // 带角度的filling words占总体的比例
  late num rotatedWordsRatio;
  late num minRotation;
  late num maxRotation;
  late num rotationRange;

  // 螺旋线相关设定
  late num angleMode;
  late num radiusStep;
  late num angleStep;

  // 螺旋线最大半径
  late num maxRadius;
}
