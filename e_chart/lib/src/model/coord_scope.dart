import 'package:e_chart/e_chart.dart';

///坐标域的表示
class CoordScope {
  final CoordType type;

  final int index;

  const CoordScope._(this.type, this.index) : assert(index >= 0);

  const CoordScope(this.type, this.index) : assert(index >= 0);

  static final Map<CoordType, Map<int, CoordScope>> _coordMap = {};

  static CoordScope from(CoordType type, int index) {
    var childMap = _coordMap.get2(type, {});
    return childMap.get2(index, CoordScope._(type, index));
  }

  @override
  int get hashCode {
    return Object.hash(type, index);
  }

  @override
  bool operator ==(Object other) {
    return other is CoordScope && other.type == type && other.index == index;
  }

  bool isGrid() {
    return type == CoordType.grid;
  }

  bool isPolar() {
    return type == CoordType.polar;
  }

  bool isParallel() {
    return type == CoordType.parallel;
  }

  bool isRadar() {
    return type == CoordType.radar;
  }

  bool isCalendar() {
    return type == CoordType.calendar;
  }

  bool isSingle() {
    return type == CoordType.custom;
  }
}
