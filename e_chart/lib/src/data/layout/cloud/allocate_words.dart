import 'dart:math';
import 'package:e_chart/e_chart.dart';

import 'types.dart';

void allocateWords(List<Keyword> words, List<Region> regions, List<num> areas, WordOption options) {
  allocateWordsToRegions(words, regions, areas, options);
  allocateWordsToExtremePoint(words, regions, areas, options);
}

void allocateWordsToRegions(List<Keyword> words, List<Region> regions, List<num> areas, WordOption options) {
  // 将单词分配到各个区域
  var keywordsNum = options.keywordsNum;
  var baseOnAreaOrDisValue = options.baseOnArea;
  num wordsMinWeight = double.maxFinite;
  for (var word in words) {
    wordsMinWeight = min(wordsMinWeight, word.weight);
  }

  num areaMax = double.minPositive;
  num totalArea = 0;
  for (var area in areas) {
    areaMax = max(area, areaMax);
    totalArea += area;
  }
  var areaMaxId = areas.indexOf(areaMax);
  var values = regions.map((region) => region.value!);

  num valueMax = double.minPositive;
  int valueMaxId = -1;
  int i = 0;
  for (var v in values) {
    if (v > valueMax) {
      valueMax = v;
      valueMaxId = i;
    }
    i++;
  }
  // 给每个区域分配单词数量和权重限制
  num wordsSum = 0;
  for (var region in regions) {
    var area = region.area;
    var value = region.value;

    var wordsNum = value! <= 18 && valueMax > 45 ? 0 : ((area! / totalArea) * keywordsNum).round();
    wordsSum += wordsNum;
    num wordsWeight = baseOnAreaOrDisValue ? area! / areaMax : value / valueMax;
    if (wordsNum < 3) {
      wordsWeight = wordsMinWeight;
    }
    region.wordsNum = wordsNum;
    region.wordsWeight = wordsWeight;
  }

  if (wordsSum != keywordsNum) {
    regions[areaMaxId].wordsNum = regions[areaMaxId].wordsNum! + keywordsNum - wordsSum;
  }
  var wordsNums = regions.map((region) => region.wordsNum!).toList();

  int currRegion = baseOnAreaOrDisValue ? areaMaxId : valueMaxId;

  // 对每个单词进行分配
  for (var word in words) {
    var failCounter = 0;
    word.regionID = -1;
    do {
      if (wordsNums[currRegion] > 0 && word.weight <= regions[currRegion].wordsWeight!) {
        // console.log(word.name)
        if ((regions[currRegion].extremePoints[0].value < 24 && word.name.length <= 5) ||
            regions[currRegion].extremePoints[0].value >= 24) {
          word.regionID = currRegion;
          wordsNums[currRegion]--;
        }
      }
      currRegion = (currRegion + 1) % regions.length;
      failCounter++;
    } while (word.regionID == -1 && failCounter < regions.length * 3);

    // 未分配则分配为value/area最大的区域
    if (word.regionID == -1) {
      word.regionID = baseOnAreaOrDisValue ? areaMaxId : valueMaxId;
    }
  }
}

void allocateWordsToExtremePoint(List<Keyword> words, List<Region> regions, List<num> areas, WordOption options) {
  var isMaxMode = options.isMaxMode;
  num wordsMinWeight = double.maxFinite;
  for (var word in words) {
    wordsMinWeight = min(wordsMinWeight, word.weight);
  }

  // 给每个极点分配单词数量和权重
  for (int i = 0; i < regions.length; i++) {
    var region = regions[i];
    var regionId = i;
    num wordsSum = 0;

    for (var ep in region.extremePoints) {
      ep.epWeight = (ep.ratio! / region.extremePoints[0].ratio!) * region.wordsWeight!;
      ep.epNumber = ep.value < 20 ? 0 : (ep.ratio! * region.wordsNum!).round();
      wordsSum += ep.epNumber!;
      ep.epWeight = max(ep.epWeight!, wordsMinWeight);
      ep.epWeight = roundFun(ep.epWeight!, 2);
    }

    if (wordsSum != region.wordsNum) {
      region.extremePoints[0].epNumber = region.extremePoints[0].epNumber! + region.wordsNum! - wordsSum;
    }
    // 给每个极点分配单词
    int currEP = 0;
    var wordsNumbers = region.extremePoints.map((ep) => ep.epNumber!).toList();

    for (var word in words) {
      if (word.regionID == regionId) {
        var failCounter = 0;
        word.epID = -1;
        do {
          if (wordsNumbers[currEP] > 0 && word.weight <= region.extremePoints[currEP].epWeight!) {
            word.epID = currEP;
            wordsNumbers[currEP]--;
          }
          currEP = (currEP + 1) % region.extremePoints.length;
          failCounter++;
        } while (word.epID == -1 && failCounter < region.extremePoints.length * 2);

        if (word.epID == -1) {
          word.epID = 0;
        }
      }
    }
  }

  List<num> computeRatios(num maxFontSize) {
    List<num> ratios = [];
    // 计算空白率
    var minFontSize = options.minFontSize;
    for (int i = 0; i < regions.length; i++) {
      var region = regions[i];
      var regionId = i;
      num area = 0;
      for (var word in words) {
        if (word.regionID == regionId) {
          var fontSize = (maxFontSize - minFontSize) * sqrt(word.weight) + minFontSize;
          var width = measureTextSize(word.name, fontSize, word.fontWeight, word.fontFamily).width;
          area += (fontSize + 1) * (width + 4);
        }
      }
      ratios.add(area / region.area!);
    }
    return ratios;
  }

  if (isMaxMode) {
    // todo
  } else {
    // 正常模式下，在给定的范围内确定最大字号
    var l = options.minFontSize, r = options.maxFontSize;
    var fontSize = r;
    while (r - l > 1) {
      var mid = ((l + r) / 2).floor();
      var ratios = computeRatios(mid);
      if (ratios.every((ratio) => ratio <= 0.65)) {
        fontSize = mid;
        l = mid;
      } else {
        r = mid;
      }
    }
    options.maxFontSize = fontSize;
  }
}
