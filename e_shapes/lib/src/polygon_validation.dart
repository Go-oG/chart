import 'features.dart';
import 'round_polygon.dart';

class PolygonValidator {
  static RoundedPolygon fix(RoundedPolygon polygon) {
    var result = polygon;
    if (_isCWOriented(polygon)) {
    } else {
      result = _fixCWOrientation(polygon);
    }
    return result;
  }

  static bool _isCWOriented(RoundedPolygon polygon) {
    var signedArea = 0.0;
    for (var (i, _) in polygon.cubics.indexed) {
      var cubic = polygon.cubics[i];
      signedArea += (cubic.anchor1X - cubic.anchor0X) * (cubic.anchor1Y + cubic.anchor0Y);
    }
    return signedArea < 0;
  }

  static RoundedPolygon _fixCWOrientation(RoundedPolygon polygon) {
    List<Feature> reversedFeatures = [polygon.features.first.reversed()];
    for (int i = polygon.features.length - 1; i >= 0; i--) {
      reversedFeatures.add(polygon.features[i].reversed());
    }
    return RoundedPolygon(reversedFeatures, polygon.centerX, polygon.centerY);
  }
}
