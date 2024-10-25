
import 'cubic.dart';
import 'feature_mapping.dart';
import 'features.dart';
import 'pair.dart';
import 'point.dart';
import 'round_polygon.dart';
import 'utils.dart';

class MeasuredPolygon {
  Measurer measurer;
  late List<MeasuredCubic> cubics;

  List<ProgressableFeature> features;

  MeasuredPolygon(this.measurer, this.features, List<Cubic> cubics, List<double> outlineProgress) {
    if (outlineProgress.length != cubics.length + 1) {
      throw "Outline progress size is expected to be the cubics size + 1";
    }
    if (outlineProgress.first != 0) {
      throw "First outline progress value is expected to be zero";
    }
    if (outlineProgress.last != 1) {
      throw "Last outline progress value is expected to be one";
    }

    List<MeasuredCubic> measuredCubics = [];
    double startOutlineProgress = 0;
    for (var (index, _) in cubics.indexed) {
      if ((outlineProgress[index + 1] - outlineProgress[index]) > distanceEpsilon) {
        measuredCubics.add(MeasuredCubic(measurer, cubics[index], startOutlineProgress, outlineProgress[index + 1]));

        startOutlineProgress = outlineProgress[index + 1];
      }
    }
    measuredCubics[measuredCubics.length - 1].updateProgressRange(endOutlineProgress: 1);
    this.cubics = measuredCubics;
  }

  MeasuredPolygon cutAndShift(double cuttingPoint) {
    // require(cuttingPoint in 0f..1f) { "Cutting point is expected to be between 0 and 1" }
    if (cuttingPoint < distanceEpsilon) return this;

    int targetIndex = (cubics.indexed
        .firstWhere((e) => cuttingPoint >= e.$2.startOutlineProgress && cuttingPoint <= e.$2.endOutlineProgress)).$1;

    var target = cubics[targetIndex];

    var tmp = target.cutAtProgress(cuttingPoint);
    var b1 = tmp.first;
    var b2 = tmp.second;
    List<Cubic> retCubics = [b2.cubic];
    for (var i = 0; i < cubics.length; i++) {
      retCubics.add(cubics[(i + targetIndex) % cubics.length].cubic);
    }
    retCubics.add(b1.cubic);
    List<double> retOutlineProgress = List.filled(cubics.length + 2, 0, growable: true);
    for (int index = 0; index < cubics.length + 2; index++) {
      double v;
      if (index == 0) {
        v = 0;
      } else if (index == cubics.length + 1) {
        v = 1;
      } else {
        var cubicIndex = (targetIndex + index - 1) % cubics.length;
        v = positiveModulo(cubics[cubicIndex].endOutlineProgress - cuttingPoint, 1);
      }
      retOutlineProgress.add(v);
    }

    List<ProgressableFeature> newFeatures = [];
    for (var (i, _) in features.indexed) {
      newFeatures.add(ProgressableFeature(positiveModulo(features[i].progress - cuttingPoint, 1), features[i].feature));
    }
    return MeasuredPolygon(measurer, newFeatures, retCubics, retOutlineProgress);
  }

  int get size => cubics.length;

  MeasuredCubic operator [](int index) => cubics[index];

  MeasuredCubic? getOrNull(int index) {
    if (index >= cubics.length) {
      return null;
    }
    return cubics[index];
  }

  static MeasuredPolygon measurePolygon(Measurer measurer, RoundedPolygon polygon) {
    List<Cubic> cubics = [];
    List<Pair<Feature, int>> featureToCubic = [];

    for (var (featureIndex, _) in polygon.features.indexed) {
      var feature = polygon.features[featureIndex];
      for (var (cubicIndex, _) in feature.cubics.indexed) {
        if (feature is Corner && cubicIndex == feature.cubics.length ~/ 2) {
          featureToCubic.add(Pair(feature, cubics.length));
        }
        cubics.add(feature.cubics[cubicIndex]);
      }
    }

    List<double> measures = [0];
    for (var item in cubics) {
      double t = measurer.measureCubic(item);
      if (t < 0) {
        throw "Measured cubic is expected to be greater or equal to zero";
      }
      measures.add(t + measures.last);
    }
    var totalMeasure = measures.last;

    List<double> outlineProgress = List.filled(measures.length, 0);
    for (var (i, _) in measures.indexed) {
      outlineProgress.add(measures[i] / totalMeasure);
    }

    List<ProgressableFeature> features = [];
    for (var (i, _) in featureToCubic.indexed) {
      var ix = featureToCubic[i].second;
      features.add(ProgressableFeature((outlineProgress[ix] + outlineProgress[ix + 1]) / 2, featureToCubic[i].first));
    }
    return MeasuredPolygon(measurer, features, cubics, outlineProgress);
  }
}

class MeasuredCubic {
  final Cubic cubic;
  final Measurer measurer;
  double startOutlineProgress;
  double endOutlineProgress;
  late double measuredSize = measurer.measureCubic(cubic);

  MeasuredCubic(this.measurer, this.cubic, this.startOutlineProgress, this.endOutlineProgress) {
    if (endOutlineProgress < startOutlineProgress) {
      throw "endOutlineProgress is expected to be equal or greater than startOutlineProgress";
    }
  }

  void updateProgressRange({double? startOutlineProgress, double? endOutlineProgress}) {
    startOutlineProgress ??= this.startOutlineProgress;
    endOutlineProgress ??= this.endOutlineProgress;

    if (endOutlineProgress < startOutlineProgress) {
      throw "endOutlineProgress is expected to be equal or greater than startOutlineProgress";
    }
    this.startOutlineProgress = startOutlineProgress;
    this.endOutlineProgress = endOutlineProgress;
  }

  Pair<MeasuredCubic, MeasuredCubic> cutAtProgress(double cutOutlineProgress) {
    double boundedCutOutlineProgress = cutOutlineProgress.clamp(startOutlineProgress, endOutlineProgress);
    double outlineProgressSize = endOutlineProgress - startOutlineProgress;
    double progressFromStart = boundedCutOutlineProgress - startOutlineProgress;

    double relativeProgress = progressFromStart / outlineProgressSize;
    double t = measurer.findCubicCutPoint(cubic, relativeProgress * measuredSize);
    List<Cubic> tmpList = cubic.split(t);
    Cubic c1 = tmpList.first;
    Cubic c2 = tmpList[1];

    return Pair(MeasuredCubic(measurer, c1, startOutlineProgress, boundedCutOutlineProgress),
        MeasuredCubic(measurer, c2, boundedCutOutlineProgress, endOutlineProgress));
  }
}

interface class Measurer {
  double measureCubic(Cubic c) {
    throw UnimplementedError();
  }

  double findCubicCutPoint(Cubic c, double m) {
    throw UnimplementedError();
  }
}

class LengthMeasurer implements Measurer {
  static const segments = 3;

  Pair<double, double> _closestProgressTo(Cubic cubic, double threshold) {
    double total = 0;
    var remainder = threshold;
    var prev = Point(cubic.anchor0X, cubic.anchor0Y);
    for (int i = 1; i <= segments; i++) {
      var progress = i / segments;
      var point = cubic.pointOnCurve(progress);
      var segment = (point - prev).distance;
      if (segment >= remainder) {
        return Pair(progress - (1.0 - remainder / segment) / segments, threshold);
      }
      remainder -= segment;
      total += segment;
      prev = point;
    }
    return Pair(1.0, total);
  }

  @override
  double findCubicCutPoint(Cubic c, double m) {
    return _closestProgressTo(c, m).first;
  }

  @override
  double measureCubic(Cubic c) {
    return _closestProgressTo(c, double.infinity).second;
  }
}
