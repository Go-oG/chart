import 'dart:math' as m;
import 'dart:ui';
import 'polygon_measure.dart';
import 'utils.dart' as util;
import 'cubic.dart';
import 'feature_mapping.dart';
import 'pair.dart';
import 'round_polygon.dart';

class Morph {
  final RoundedPolygon start;
  final RoundedPolygon end;

  Morph(this.start, this.end);

  late final List<Pair<Cubic, Cubic>> _morphMatch = _match(start, end);

  List<Pair<Cubic, Cubic>> get morphMatch => _morphMatch;

  List<double> calculateBounds([List<double>? bounds, bool approximate = true]) {
    bounds ??= List.filled(4, 0);
    start.calculateBounds(bounds, approximate);
    var minX = bounds[0];
    var minY = bounds[1];
    var maxX = bounds[2];
    var maxY = bounds[3];
    end.calculateBounds(bounds, approximate);
    bounds[0] = m.min(minX, bounds[0]);
    bounds[1] = m.min(minY, bounds[1]);
    bounds[2] = m.max(maxX, bounds[2]);
    bounds[3] = m.max(maxY, bounds[3]);
    return bounds;
  }

  List<double> calculateMaxBounds([List<double>? bounds]) {
    bounds ??= List.filled(
      4,
      0,
    );
    start.calculateMaxBounds(bounds);
    var minX = bounds[0];
    var minY = bounds[1];
    var maxX = bounds[2];
    var maxY = bounds[3];
    end.calculateMaxBounds(bounds);
    bounds[0] = m.min(minX, bounds[0]);
    bounds[1] = m.min(minY, bounds[1]);
    bounds[2] = m.max(maxX, bounds[2]);
    bounds[3] = m.max(maxY, bounds[3]);
    return bounds;
  }

  List<Cubic> asCubics(double progress) {
    List<Cubic> resultList = [];
    Cubic? firstCubic;
    Cubic? lastCubic;

    for (var (i, _) in _morphMatch.indexed) {
      var cubic = Cubic.fromList(List.generate(8, (it) {
        return util.interpolate(_morphMatch[i].first.points[it], _morphMatch[i].second.points[it], progress);
      }));

      firstCubic ??= cubic;
      if (lastCubic != null) {
        resultList.add(lastCubic);
      }
      lastCubic = cubic;
    }

    if (lastCubic != null && firstCubic != null) {
      resultList.add(Cubic(lastCubic.anchor0X, lastCubic.anchor0Y, lastCubic.control0X, lastCubic.control0Y,
          lastCubic.control1X, lastCubic.control1Y, firstCubic.anchor0X, firstCubic.anchor0Y));
    }
    return resultList;
  }

  void forEachCubic(double progress, MutableCubic? mutableCubic, void Function(MutableCubic) callback) {
    mutableCubic ??= MutableCubic();

    for (var (i, _) in morphMatch.indexed) {
      mutableCubic.interpolate(morphMatch[i].first, morphMatch[i].second, progress);
      callback(mutableCubic);
    }
  }

  static List<Pair<Cubic, Cubic>> _match(RoundedPolygon p1, RoundedPolygon p2) {
    var measuredPolygon1 = MeasuredPolygon.measurePolygon(LengthMeasurer(), p1);
    var measuredPolygon2 = MeasuredPolygon.measurePolygon(LengthMeasurer(), p2);

    var features1 = measuredPolygon1.features;
    var features2 = measuredPolygon2.features;

    var doubleMapper = featureMapper(features1, features2);
    var polygon2CutPoint = doubleMapper.map(0);

    MeasuredPolygon bs1 = measuredPolygon1;
    MeasuredPolygon bs2 = measuredPolygon2.cutAndShift(polygon2CutPoint);

    List<Pair<Cubic, Cubic>> ret = [];
    var i1 = 0;
    var i2 = 0;
    var b1 = bs1.getOrNull(i1++);
    var b2 = bs2.getOrNull(i2++);

    while (b1 != null && b2 != null) {
      double b1a = (i1 == bs1.size) ? 1 : b1.endOutlineProgress;
      double b2a =
          (i2 == bs2.size) ? 1 : doubleMapper.mapBack(util.positiveModulo(b2.endOutlineProgress + polygon2CutPoint, 1));
      var minb = m.min(b1a, b2a);

      MeasuredCubic seg1;
      MeasuredCubic? newb1;

      if (b1a > minb + util.angleEpsilon) {
        var p = b1.cutAtProgress(minb);
        seg1 = p.first;
        newb1 = p.second;
      } else {
        seg1 = b1;
        newb1 = bs1.getOrNull(i1++);
      }

      MeasuredCubic seg2;
      MeasuredCubic? newb2;

      if (b2a > minb + util.angleEpsilon) {
        var p = b2.cutAtProgress(util.positiveModulo(doubleMapper.map(minb) - polygon2CutPoint, 1));
        seg2 = p.first;
        newb2 = p.second;
      } else {
        seg2 = b2;
        newb2 = bs2.getOrNull(i2++);
      }
      ret.add(Pair(seg1.cubic, seg2.cubic));
      b1 = newb1;
      b2 = newb2;
    }
    if (b1 != null || b2 != null) {
      throw "Expected both Polygon's Cubic to be fully matched";
    }
    return ret;
  }

  Path toPath(double progress, [Path? path]) {
    return util.toPath(path ?? Path(), asCubics(progress));
  }
}
