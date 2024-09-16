// import 'package:e_chart/e_chart.dart';
// import 'package:e_chart/src/transform/cloud/wordle.dart';
//
// import 'allocate_words.dart';
// import 'filling.dart';
// import 'process_distance_field.dart';
// import 'process_words.dart';
// import 'text_process.dart';
// import 'types.dart';
//
// class ShapeWordle {
//   void generate(List<Word> texts) {
//     var option = WordOption(400, 400, 200);
//     var words = processWordWeight(texts);
//     var pair = processWordStyleAndAngle(words, option);
//
//     var keyWords = pair.first;
//     var fillingWords = pair.second;
//
//     List<List<List<num>>> distRaw = [];
//
//     List<List<CPoint>> contours = [];
//
//     List<List<num>> groupRaw = [];
//     List<num> areas = [];
//
//     var imageData = processImageData(distRaw, groupRaw, option);
//     var regions = processDistanceField(imageData.first, contours, areas);
//     allocateWords(keyWords, regions, areas, option);
//     generateWordle(keyWords, regions, imageData.second, option);
//
//     var renderKeywords = createRenderKeywords(keyWords);
//     var renderFillWords = allocateFillingWords(keyWords, fillingWords, imageData.second, option);
//   }
// }
//
// void drawKeyWords(CCanvas canvas, WordOption option, List<RenderKeyWord> keyWords) {
//   for (var word in keyWords) {
//     canvas.save();
//
//     canvas.restore();
//   }
// }
