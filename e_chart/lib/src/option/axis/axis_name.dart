import 'package:e_chart/e_chart.dart';

///轴名字配置
class AxisName {
  final DynamicText name;
  final Align2 align;
  final double nameGap;
  final LabelStyle labelStyle;
  final double rotate;

  const AxisName(
    this.name, {
    this.align = Align2.end,
    this.nameGap = 8,
    this.labelStyle = const LabelStyle(),
    this.rotate = 0,
  });

  AxisName copy({
    DynamicText? name,
    Align2? align,
    double? nameGap,
    LabelStyle? labelStyle,
    double? rotate,
  }) {
    return AxisName(
      name ?? this.name,
      align: align ?? this.align,
      nameGap: nameGap ?? this.nameGap,
      labelStyle: labelStyle ?? this.labelStyle,
      rotate: rotate ?? this.rotate,
    );
  }

  @override
  int get hashCode {
    return Object.hash(name, align, nameGap, labelStyle, rotate);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AxisName &&
        other.name == name &&
        other.align == align &&
        other.nameGap == nameGap &&
        other.labelStyle == labelStyle &&
        other.rotate.equal(rotate);
  }
}
