

import 'double_mapping.dart';
import 'features.dart';
import 'pair.dart';

typedef MeasuredFeatures = List<ProgressableFeature>;

final class ProgressableFeature {
  final double progress;
  final Feature feature;

  ProgressableFeature(this.progress, this.feature);
}

DoubleMapper featureMapper(MeasuredFeatures features1, MeasuredFeatures features2) {
  List<ProgressableFeature> filteredFeatures1 = [];
  for (var item in features1) {
    if (item.feature is Corner) {
      filteredFeatures1.add(item);
    }
  }

  List<ProgressableFeature> filteredFeatures2 = [];
  for (var item in features2) {
    if (item.feature is Corner) {
      filteredFeatures2.add(item);
    }
  }

  MeasuredFeatures m1, m2;

  if (filteredFeatures1.length > filteredFeatures2.length) {
    m1 = _doMapping(filteredFeatures2, filteredFeatures1);
    m2 = filteredFeatures2;
  } else {
    m1 = filteredFeatures1;
    m2 = _doMapping(filteredFeatures1, filteredFeatures2);
  }

  List<Pair<double, double>> mm = [];
  for (var (i, _) in m1.indexed) {
    if (i == m2.length) break;
    mm.add(Pair(m1[i].progress, m2[i].progress));
  }
  return DoubleMapper(mm);
}

double _featureDistSquared(Feature f1, Feature f2) {
  if (f1 is Corner && f2 is Corner && f1.convex != f2.convex) {
    return double.maxFinite;
  }
  var c1x = (f1.cubics.first.anchor0X + f1.cubics.last.anchor1X) / 2;
  var c1y = (f1.cubics.first.anchor0Y + f1.cubics.last.anchor1Y) / 2;
  var c2x = (f2.cubics.first.anchor0X + f2.cubics.last.anchor1X) / 2;
  var c2y = (f2.cubics.first.anchor0Y + f2.cubics.last.anchor1Y) / 2;
  var dx = c1x - c2x;
  var dy = c1y - c2y;
  return dx * dx + dy * dy;
}

MeasuredFeatures _doMapping(MeasuredFeatures f1, MeasuredFeatures f2) {
  int ix = -1;
  double minV = 0;
  for (var (i, v) in f2.indexed) {
    double v = _featureDistSquared(f1[0].feature, f2[i].feature);
    if (ix == -1) {
      ix = i;
      minV = v;
    } else {
      if (v < minV) {
        ix = i;
      }
    }
  }

  var m = f1.length;
  var n = f2.length;
  List<ProgressableFeature> ret = [f2[ix]];
  int lastPicked = ix;

  for (int i = 1; i < m; i++) {
    int last = ix - (m - i);
    if (last <= lastPicked) {
      last += n;
    }
    int best = -1;
    double minV = 0;
    for (var i = lastPicked + 1; i <= last; i++) {
      var v = _featureDistSquared(f1[i].feature, f2[i % n].feature);
      if (best == -1) {
        minV = v;
        best = i;
      } else {
        if (v < minV) {
          minV = v;
          best = i;
        }
      }
    }
    ret.add(f2[best % n]);
    lastPicked = best;
  }
  return ret;
}
