import 'package:e_chart/src/model/error.dart';

import 'types.dart';

List<Word> processWordWeight(List<Word> words) {
  for (var word in words) {
    if (word.weight <= 0) {
      throw ArgumentsError("weight must >0");
    }
  }
  List<Word> wordList = List.from(words);
  wordList.sort((a, b) => b.weight.compareTo(a.weight));
  var maxWeight = wordList.first.weight;
  for (var word in wordList) {
    word.weight = word.weight / maxWeight;
  }
  return wordList;
}
