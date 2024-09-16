import 'package:e_chart/e_chart.dart';

class AxisDim {
  static final Map<Dim, Map<int, AxisDim>> _dimMap = {};

  static AxisDim of(Dim dim, int index) {
    var childMap = _dimMap.get2(dim, {});
    return childMap.get2(index, AxisDim._(dim, index));
  }

  final Dim dim;
  final int index;

  const AxisDim._(this.dim, this.index) : assert(index >= 0);

  bool get isCol => dim.isX;

  bool get isRow => dim.isY;

  @override
  int get hashCode => Object.hash(dim, index);

  @override
  bool operator ==(Object other) {
    return other is AxisDim && other.dim == dim && other.index == index;
  }

  @override
  String toString() {
    return "AxisDim['dim':${dim.name},'index':$index]";
  }
}

class GridAxisDim extends AxisDim {
  final bool isXAxis;

  const GridAxisDim(this.isXAxis, int index) : super._(isXAxis ? Dim.x : Dim.y, index);

  @override
  bool operator ==(Object other) {
    return other is GridAxisDim && other.dim == dim && other.index == index && other.isXAxis == isXAxis;
  }
}

class PolarAxisDim extends AxisDim {
  final bool isRadius;

  const PolarAxisDim(this.isRadius, int index) : super._(isRadius ? Dim.y : Dim.x, index);

  @override
  bool operator ==(Object other) {
    return other is PolarAxisDim && other.dim == dim && other.index == index && other.isRadius == isRadius;
  }
}
