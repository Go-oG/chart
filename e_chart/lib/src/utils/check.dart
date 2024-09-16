import 'package:e_chart/src/model/error.dart';

void checkArgs(bool value, [String? msg]) {
  if (!value) {
    throw ArgumentsError(msg ?? "违法参数");
  }
}

void checkDataType(dynamic data) {
  if (data is String || data is DateTime || data is num) {
    return;
  }
  throw TypeMatchError('只接受String DateTime num');
}

///检查给定的两个数据的引用地址是否一样
///如果一样则抛出异常
void checkRef(dynamic a, dynamic b, [String? msg]) {
  if (a == null && b == null) {
    return;
  }
  if (identical(a, b)) {
    throw ChartError(msg ?? "a b引用的地址相同");
  }
}

bool isEmpty(String? str) {
  return str == null || str.isEmpty;
}

bool isNotEmpty(String? str) {
  return str != null && str.isNotEmpty;
}
