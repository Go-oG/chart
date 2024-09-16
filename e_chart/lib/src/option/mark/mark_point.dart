import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';

class MarkPoint {
  final MarkPointData data;
  final bool touch;
  final LabelStyle? labelStyle;
  final int precision; //精度

  // late TextElement _label;

  const MarkPoint(
    this.data, {
    this.touch = false,
    this.labelStyle,
    this.precision = 1,
  });

  MarkPoint copy({
    MarkPointData? data,
    bool? touch,
    LabelStyle? labelStyle,
    int? precision,
  }) {
    return MarkPoint(
      data ?? this.data,
      touch: touch ?? this.touch,
      labelStyle: labelStyle ?? this.labelStyle,
      precision: precision ?? this.precision,
    );
  }

  void draw(Canvas2 canvas, Paint paint, Offset offset, [DynamicText? text]) {
    // symbol.draw(canvas, paint, offset);
    // if (_label.text != text && _label.offset != offset) {
    //   _label.updatePainter(text: text ?? DynamicText.empty, offset: offset);
    // }
    // _label.draw(canvas, paint);
  }

  @override
  int get hashCode {
    return Object.hash(data, touch, labelStyle, precision);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MarkPoint &&
        other.data == data &&
        other.touch == touch &&
        other.labelStyle == labelStyle &&
        other.precision == precision;
  }
}

class MarkPointData {
  final List<dynamic>? data;
  final ValueType? valueType;
  final int? valueDimIndex;

  final List<SNumber>? coord;

  MarkPointData._({this.data, this.valueType, this.valueDimIndex, this.coord}) {
    if (valueType == null && coord == null && data == null) {
      throw ChartError("valueType and coord not all be null ");
    }
    if (valueType != null && valueDimIndex == null) {
      throw ChartError("if valueType not null,valueDimIndex must not null");
    }
    if (coord != null && coord!.length != 2) {
      throw ChartError("coord length must==2");
    }
  }

  MarkPointData.data(List<dynamic> data) : this._(data: data);

  MarkPointData.type(ValueType type, int dimIndex) : this._(valueType: type, valueDimIndex: dimIndex);

  MarkPointData.coord(List<SNumber> coord) : this._(coord: coord);

  @override
  int get hashCode {
    return Object.hash(data, valueType, valueDimIndex, coord);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MarkPointData &&
        listEquals(other.data, data)&&
        other.valueType == valueType &&
        other.valueDimIndex == valueDimIndex &&
        listEquals(other.coord, coord);
  }
}

class MarkPointNode {
  final MarkPoint markPoint;
  Offset offset = Offset.zero;
  dynamic data;

  MarkPointNode(this.markPoint, this.data);
}
