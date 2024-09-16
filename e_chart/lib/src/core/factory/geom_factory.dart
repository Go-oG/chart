import '../../geom/geom.dart';
import '../context.dart';
import '../render/view.dart';

final geomFactory = GeomFactory._();

final class GeomFactory {
  GeomFactory._();

  late final List<GeomConvert> _convertList = [];

  void addConvert(GeomConvert convert) {
    _convertList.insert(0, convert);
  }

  void removeConvert(GeomConvert convert) {
    _convertList.remove(convert);
  }

  void clearConvert() {
    _convertList.clear();
  }

  ChartView? convert(Context context, Geom geom) {
    for (var sc in _convertList) {
      ChartView? v = sc.convert(context, geom);
      if (v != null) {
        return v;
      }
    }
    return null;
  }
}

interface class GeomConvert {
  ChartView? convert(Context context, Geom geom) {
    return null;
  }
}
