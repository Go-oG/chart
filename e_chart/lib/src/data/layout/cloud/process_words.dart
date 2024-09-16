import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'types.dart';

Pair<List<Keyword>, List<FillWord>> processWordStyleAndAngle(List<Word> words, WordOption options) {
  var pair = _separateWords(words, options);
  for (var word in pair.first) {
    word.angle = _calcAngle(word.weight, options.angleMode);
  }
  return pair;
}

Pair<List<Keyword>, List<FillWord>> _separateWords(List<Word> words, WordOption option) {
  if (words.length < option.keywordsNum) {
    throw ChartError("At least ${option.keywordsNum} words is required. We got ${words.length} words instead");
  }

  List<Keyword> keywords = [];
  for (int i = 0; i < option.keywordsNum; i++) {
    var word = keywords[i];
    var keyWord = Keyword(
      word.name,
      word.weight < 0.02 ? 0.02 : roundFun(word.weight, 3),
      option.fontFamily,
      option.fontWeight,
    );
    keywords.add(keyWord);
  }

  int start = words.length >= 160 ? option.keywordsNum : 0;
  int end = min(words.length, start + 200);

  List<FillWord> fillingWords = [];
  for (int i = start; i < end; i++) {
    var word = keywords[i];
    var keyWord = FillWord(word.name, 0.05, option.fontFamily, option.fontWeight);
    fillingWords.add(keyWord);
  }

  while (fillingWords.length < 200) {
    fillingWords.add(fillingWords[randomInt(0, fillingWords.length)]);
  }
  return Pair(keywords, fillingWords);
}

num _calcAngle(num weight, num angleMode) {
  const max = pi / 2;
  const min = -pi / 2;

  switch (angleMode) {
    case 0:
      return 0;
    case 1:
      if (weight > 0.5) {
        return 0;
      }
      if (random() > 0.6) {
        return random() > 0.5 ? max : min;
      } else {
        return 0;
      }
    case 2:
      return random() * (max - min + 1) + min;
    case 3:
      return pi / 4;
    case 4:
      return -pi / 4;
    case 5:
      if (random() > 0.5) {
        return pi / 4;
      } else {
        return -pi / 4;
      }
    default:
      return 0;
  }
}
