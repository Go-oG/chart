// import 'dart:math';
//
// import 'package:e_chart/e_chart.dart';
//
// import '../../utils/math_util.dart';
// import 'helper.dart';
// import 'types.dart';
//
// List<RenderFillWord> allocateFillingWords(
//   List<Keyword> keywords,
//   List<FillWord> fillingWords,
//   TwoDimArray group,
//   WordOption option,
// ) {
//   var canvasWidth = option.width;
//   var canvasHeight = option.height;
//   var fillingFontSize = option.fillFontSize;
//   var angleMode = option.angleMode;
//
//   var fillSet = FillSetting();
//   fillSet.canvasWidth = canvasWidth;
//   fillSet.canvasHeight = canvasHeight;
//   fillSet.gridSize = 1;
//   fillSet.rotatedWordsRatio = 0.5;
//   fillSet.minRotation = -pi / 2;
//   fillSet.maxRotation = pi / 2;
//   fillSet.angleMode = angleMode;
//   fillSet.radiusStep = 0.5;
//   fillSet.angleStep = 10;
//
//   // 后面代码填充
//   fillSet.gridWidth = 0;
//   fillSet.gridHeight = 0;
//   fillSet.rotationRange = 0;
//   fillSet.maxRadius = 0;
//
//   List<RenderFillWord> renderFillWordList = [];
//
//   fillSet.gridWidth = canvasWidth ~/ fillSet.gridSize;
//   fillSet.gridHeight = canvasHeight ~/ fillSet.gridSize;
//   fillSet.rotationRange = (fillSet.maxRotation - fillSet.minRotation).abs();
//   fillSet.maxRadius =
//       (sqrt(fillSet.canvasWidth * fillSet.canvasWidth + fillSet.canvasHeight * fillSet.canvasHeight) / 2).floor();
//
//   // 将canvas划分成格子，进行分布
//   var grid = createGrid(keywords, group, fillSet);
//
//   // 多次填充，保证填充率
//   num fontSize = fillingFontSize, alpha = 1;
//   num deltaFontSize = 2, deltaAlpha = 0;
//   num fillingTimes = 10;
//
//   for (var i = 0; i < fillingTimes; i++) {
//     for (var word in fillingWords) {
//       _putWord(word, fontSize, alpha, grid, renderFillWordList, fillSet);
//     }
//     fontSize = fontSize > deltaFontSize ? fontSize - deltaFontSize : deltaFontSize;
//     alpha = alpha > deltaAlpha ? alpha - deltaAlpha : deltaAlpha;
//   }
//
//   return renderFillWordList;
// }
//
// List<RenderKeyWord> createRenderKeywords(List<Keyword> keywords) {
//   return keywords.takeWhile((word) {
//     return word.state == true && word.position != null;
//   }).map((word) {
//     var tmp = RenderKeyWord(
//       word.name,
//       word.position!.x,
//       word.position!.y,
//       -word.width! / 2,
//       word.width! / 2,
//       word.fontSize,
//       word.fontFamily,
//       word.fontWeight,
//       word.angle ?? 0,
//     );
//     return tmp;
//   }).toList();
// }
//
// TwoDimArray createGrid(List<Keyword> keywords, TwoDimArray group, FillSetting setting) {
//   bool isPointInShape(List<num> point) => group.get(point[0], point[1]) > 0;
//   var canvasWidth = setting.canvasWidth;
//   var canvasHeight = setting.canvasHeight;
//   var gridSize = setting.gridSize;
//
//   var grid = TwoDimArray(setting.gridWidth, setting.gridHeight, 0);
//   var canvas = createCanvas(canvasWidth, canvasHeight);
//   var ctx = canvas.getContext("2d");
//   var backgroundColor = "#000000";
//   ctx.fillStyle = backgroundColor;
//   ctx.fillRect(0, 0, canvasWidth, canvasHeight);
//   for (var word in keywords) {
//     if (word.state == true) {
//       drawKeyword(ctx, word, "#FF0000");
//     }
//   }
//
//   var imageData = ctx.getImageData(0, 0, canvasWidth, canvasHeight).data;
//   var backgroundPixel = hexToRgb(backgroundColor);
//
//   for (var gridX = 0; gridX < setting.gridWidth; gridX++) {
//     for (var gridY = 0; gridY < setting.gridHeight; gridY++) {
//       grid:
//       for (var offsetX = 0; offsetX < gridSize; offsetX++) {
//         for (var offsetY = 0; offsetY < gridSize; offsetY++) {
//           var [x, y] = [gridX * gridSize + offsetX, gridY * gridSize + offsetY];
//           if (imageData[(y * canvasWidth + x) * 4] == backgroundPixel[0] && isPointInShape([x, y])) {
//             grid.set(gridX, gridY, 1);
//             break grid;
//           }
//         }
//       }
//     }
//   }
//
//   return grid;
// }
//
// bool _putWord(
//   FillWord word,
//   num fontSize,
//   num alpha,
//   TwoDimArray grid,
//   List<RenderFillWord> renderFillWords,
//   FillSetting setting,
// ) {
//   var canvasWidth = setting.canvasWidth;
//   var canvasHeight = setting.canvasHeight;
//   var radiusStep = setting.radiusStep;
//   var angleStep = setting.angleStep;
//   var maxRadius = setting.maxRadius;
//   var gridSize = setting.gridSize;
//
//   List<num> getSpiralPoint(num angle, num r) {
//     return [r * cos((angle / 180) * pi), r * sin((angle / 180) * pi)];
//   }
//
//   ///[List<num>,num]
//   List<dynamic> getRandomPosition() {
//     var offset = 300;
//     var center = [canvasWidth / 2, canvasHeight / 2];
//     var [xMin, xMax] = [center[0] - offset, center[0] + offset];
//     var [yMin, yMax] = [center[1] - offset, center[1] + offset];
//
//     var x = (random() * (xMax - xMin + 1) + xMin).round();
//     var y = (random() * (yMax - yMin + 1) + yMin).round();
//     var distance = calDistance([x, y], center);
//     return [
//       [x, y],
//       distance
//     ];
//   }
//
//   var wordAngle = _getRotateDeg(setting);
//   var wordPixels = _getTextPixels(word, wordAngle, fontSize, setting);
//   if (wordPixels == null) return false;
//
//   var rp = getRandomPosition();
//   List<num> center = rp.first;
//   num distance = rp.last;
//
//   var radius = maxRadius + distance;
//
//   num angle = 0;
//   for (num r = 0; r < radius; r += radiusStep) {
//     var [dX, dY] = getSpiralPoint(angle, r);
//     var [x, y] = [center[0] + dX, center[1] + dY];
//
//     if (x >= 0 &&
//         y >= 0 &&
//         x < canvasWidth &&
//         y < canvasHeight &&
//         _canPutWordAtPoint(grid, wordPixels, x, y, setting)) {
//       var tw = RenderFillWord(word.name, fontSize, word.fontFamily, word.fontWeight, wordAngle, alpha);
//       renderFillWords.add(tw);
//       return true;
//     }
//     angle = angle >= 360 ? 0 : angle + angleStep * ((radius - r) / radius);
//   }
//   return false;
// }
//
// bool _canPutWordAtPoint(TwoDimArray grid, List<CPoint> wordPixels, num x, num y, FillSetting settings) {
// // 遍历像素,看是否能放置
//   var gridWidth = settings.gridWidth;
//   var gridHeight = settings.gridHeight;
//   var gridSize = settings.gridSize;
//
//   for (var point in wordPixels) {
//     var gridX = x / gridSize + point.x, gridY = y / gridSize + point.y;
//     if (gridX < 0 || gridY < 0 || gridX >= gridWidth || gridY >= gridHeight) return false;
//
//     if (grid.get(gridX, gridY) == 0) {
//       return false;
//     }
//   }
//
// // 可放置则更新grid
//   for (var point in wordPixels) {
//     var gridX = x / gridSize + point.x;
//     var gridY = y / gridSize + point.y;
//     grid.set(gridX, gridY, 0);
//   }
//   return true;
// }
//
// num _getRotateDeg(FillSetting setting) {
//   var rotatedWordsRatio = setting.rotatedWordsRatio;
//   var angleMode = setting.angleMode;
//   var minRotation = setting.minRotation;
//   var maxRotation = setting.maxRotation;
//   var rotationRange = setting.rotationRange;
//   // 根据设定的filling word mode 去返回角度
//   if (angleMode == 2) {
//     // 随机角度
//     return random() * (maxRotation - minRotation + 1) + minRotation;
//   }
//   if (angleMode == 3) {
//     // 45度向上 \\
//     return pi / 4;
//   }
//   if (angleMode == 4) {
//     // 4-45度向下//
//     return -pi / 4;
//   }
//   if (angleMode == 5) {
//     // 5-45度向上以及向下 /\
//     return random() > 0.5 ? pi / 4 : -pi / 4;
//   }
//
//   // 0-全横，1-横竖 模式下的filling words
//   return random() > rotatedWordsRatio ? 0 : minRotation + (random() * 2).floor() * rotationRange;
// }
//
// List<CPoint>? _getTextPixels(FillWord word, num angle, num fontSize, FillSetting setting) {
//   if (fontSize < 0) return null;
//   var gridSize = setting.gridSize;
//   var canvasWidth = 200, canvasHeight = 200;
//   List<CPoint> wordPixels = [];
//   var gridWidth = canvasWidth / gridSize, gridHeight = canvasHeight / gridSize;
//
//   var canvas = createCanvas(canvasWidth, canvasHeight);
//   var ctx = canvas.getContext("2d");
//   var backgroundColor = "#000000";
//   ctx.fillStyle = backgroundColor;
//   ctx.fillRect(0, 0, canvasWidth, canvasHeight);
//
//   var x = canvasWidth / 2, y = canvasHeight / 2;
//   drawFillingword(ctx, word, x, y, fontSize, angle, "#ff0000");
//
//   var [baseGridX, baseGridY] = [x / gridSize, y / gridSize];
//
//   var imageData = ctx.getImageData(0, 0, canvasWidth, canvasHeight).data;
//   for (var gridX = 0; gridX < gridWidth; gridX++) {
//     for (var gridY = 0; gridY < gridHeight; gridY++) {
//       grid:
//       for (var offsetX = 0; offsetX < gridSize; offsetX++) {
//         for (var offsetY = 0; offsetY < gridSize; offsetY++) {
//           var [x, y] = [gridX * gridSize + offsetX, gridY * gridSize + offsetY];
//           if (imageData[(y * canvasWidth + x) * 4] != 0) {
//             wordPixels.add(CPoint(gridX - baseGridX, gridY - baseGridY));
//             break grid;
//           }
//         }
//       }
//     }
//   }
//
//   return wordPixels;
// }
