import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

String randomId() {
  return _uuid.v4().replaceAll('-', '');
}

String formatNumber(num number, [int fractionDigits = 2]) {
  String s = number.toStringAsFixed(fractionDigits);
  int index = s.indexOf('.');
  if (index == -1) {
    return s;
  }

  while (s.isNotEmpty) {
    if (s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    } else if (s.endsWith('.')) {
      s = s.substring(0, s.length - 1);
      break;
    } else {
      break;
    }
  }
  if (s.isEmpty) {
    return '0';
  }
  return s;
}

bool isWeb = kIsWeb;

bool isPhone = !kIsWeb && (Platform.isIOS || Platform.isAndroid);

bool isDesktop = kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isFuchsia || Platform.isLinux;

///依据数据类型生成不同的key
String key(dynamic data) {
  if (data == null) {
    return "null";
  }
  if (data is num) {
    if (data is int) {
      return "$data";
    }
    return data.toStringAsFixed(7);
  }
  if (data is String) {
    return data;
  }
  if (data is DateTime) {
    return "${data.millisecondsSinceEpoch}";
  }
  return data.toString();
}

bool numEqual(double a, double b, [double epsilon = 1e-8]) {
  return (a - b).abs() < epsilon;
}
