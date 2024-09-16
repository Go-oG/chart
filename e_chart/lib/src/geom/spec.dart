import 'package:e_chart/e_chart.dart';

abstract class SpecPick<T> {
  final String field;

  SpecPick(this.field);

  T pick(DataNode node, RawData data, double ratio);
}

class ShapeSpec extends SpecPick<ShapeType> {
  final List<ShapeType> types;
  final Fun2<RawData, ShapeType>? typeFun;

  ShapeSpec(super.field, this.types, [this.typeFun]);

  @override
  ShapeType pick(DataNode node, RawData data, double ratio) {
    var fun = typeFun;
    if (fun != null) {
      return fun.call(data);
    }

    if (types.isEmpty) {
      return ShapeType.empty;
    }
    if (types.length == 1 || isEmpty(field)) {
      return types.first;
    }
    var index = (ratio * types.length).toInt();
    if (index >= types.length) {
      index = types.length - 1;
    }
    return types[index];
  }
}

class StyleSpec extends SpecPick<CStyle> {
  final List<CStyle> styles;
  final Fun2<RawData, CStyle>? styleFun;

  StyleSpec(super.field, this.styles, [this.styleFun]);

  @override
  CStyle pick(DataNode node, RawData data, double ratio) {
    var fun = styleFun;
    if (fun != null) {
      return fun.call(data);
    }
    if (styles.isEmpty) {
      return AreaStyle.empty;
    }
    if (styles.length == 1 || isEmpty(field)) {
      return styles.first;
    }

    var value = data.get2(field);
    if (value == null) {
      return AreaStyle.empty;
    }
    var index = (ratio * styles.length).toInt();
    if (index >= styles.length) {
      index = styles.length - 1;
    }
    return styles[index];
  }
}

class SizeSpec extends SpecPick<double> {
  final List<double> sizeList;
  final Fun2<RawData, double>? sizeFun;

  SizeSpec(super.field, this.sizeList, [this.sizeFun]);

  @override
  double pick(DataNode node, RawData data, double ratio) {
    var fun = sizeFun;
    if (fun != null) {
      return fun.call(data);
    }
    if (sizeList.isEmpty) {
      return 0;
    }
    if (sizeList.length == 1 || isEmpty(field)) {
      return sizeList.first;
    }

    var value = data.get2(field);
    if (value == null) {
      return 0;
    }

    return sizeList.first + (sizeList.last - sizeList.first) * ratio;
  }
}
