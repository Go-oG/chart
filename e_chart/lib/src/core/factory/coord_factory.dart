import 'package:e_chart/e_chart.dart';

final coordFactory = CoordFactory._();

final class CoordFactory {
  CoordFactory._();

  late final List<CoordConvert> _convertList = [];

  void addConvert(CoordConvert convert) {
    _convertList.insert(0, convert);
  }

  void removeConvert(CoordConvert convert) {
    _convertList.remove(convert);
  }

  void clearConvert() {
    _convertList.clear();
  }

  CoordView? convert(Context context, Coord c) {
    for (var sc in _convertList) {
      CoordView? v = sc.convert(context, c);
      if (v != null) {
        return v;
      }
    }
    return null;
  }
}

abstract class CoordConvert {
  CoordView? convert(Context context, Coord config);
}
