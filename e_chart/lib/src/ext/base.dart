import 'package:flutter/painting.dart';

import '../types.dart';
import '../model/text.dart';

extension StringExt on String {
  DynamicText toText() {
    return DynamicText(this);
  }

  num toNum() {
    return double.parse(this);
  }

  double toDouble() {
    return double.parse(this);
  }

  int toInt() {
    return int.parse(this);
  }
}

extension MapExt<K, V> on Map<K, V> {
  V get2(K key, V defaultValue) {
    var value = this[key];
    if (value == null) {
      value = defaultValue;
      this[key] = defaultValue;
    }
    return value!;
  }

  V get3(K key, Fun1<V> call) {
    var value = this[key];
    if (value == null) {
      var v2 = call.call();
      value = v2;
      this[key] = v2;
    }
    return value!;
  }

  Map<K, V> copy() {
    Map<K, V> resultMap = {};
    for (var item in entries) {
      resultMap[item.key] = item.value;
    }
    return resultMap;
  }
}

extension TextSpanExt on TextSpan {
  DynamicText toText() {
    return DynamicText(this);
  }
}

extension TextStyleExt on TextStyle {
  TextPainter toPainter(String text,
      {TextAlign textAlign = TextAlign.center,
      TextDirection textDirection = TextDirection.ltr,
      int? maxLines,
      String? ellipsis,
      double textScaleFactor = 1,
      TextWidthBasis textWidthBasis = TextWidthBasis.longestLine}) {
    return TextPainter(
      textScaler: TextScaler.linear(textScaleFactor),
      text: TextSpan(text: text, style: this),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      ellipsis: ellipsis,
      textWidthBasis: textWidthBasis,
    );
  }
}
