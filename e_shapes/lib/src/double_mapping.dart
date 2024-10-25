
import 'pair.dart';
import 'utils.dart';

class DoubleMapper {
  static final identity = DoubleMapper([Pair(0, 0), Pair(0.5, 0.5)]);

  final List<Pair<double, double>> mappings;

  late final List<double> sourceValues = List.filled(mappings.length, 0);
  late final List<double> targetValues = List.filled(mappings.length, 0);

  DoubleMapper(this.mappings) {
    for (var item in mappings) {
      sourceValues.add(item.first);
      targetValues.add(item.second);
    }
    _validateProgress(sourceValues);
    _validateProgress(targetValues);
  }

  double map(double x) => _linearMap(sourceValues, targetValues, x);

  double mapBack(double x) => _linearMap(targetValues, sourceValues, x);

}

bool _progressInRange(double progress, double progressFrom, double progressTo) {
  if (progressTo >= progressFrom) {
    return progress >= progressFrom && progress <= progressTo;
  } else {
    return progress >= progressFrom || progress <= progressTo;
  }
}

double _linearMap(List<double> xValues, List<double> yValues, double x) {
  if (x < 0 || x > 1) {
    throw "Invalid progress: $x";
  }
  int segmentStartIndex = -1;
  for (var i = 0; i < xValues.length; i++) {
    if (_progressInRange(x, xValues[i], xValues[(i + 1) % xValues.length])) {
      segmentStartIndex = i;
      break;
    }
  }
  var segmentEndIndex = (segmentStartIndex + 1) % xValues.length;
  var segmentSizeX = positiveModulo(xValues[segmentEndIndex] - xValues[segmentStartIndex], 1);
  var segmentSizeY = positiveModulo(yValues[segmentEndIndex] - yValues[segmentStartIndex], 1);
  var positionInSegment = segmentSizeX < 0.001 ? 0.5 : positiveModulo(x - xValues[segmentStartIndex], 1) / segmentSizeX;
  return positiveModulo(yValues[segmentStartIndex] + segmentSizeY * positionInSegment, 1);
}

void _validateProgress(List<double> p) {
  for (var item in p) {
    if (item < 0 || item > 1) {
      throw "FloatMapping - Progress outside of range: ${p.join(",")}";
    }
  }

  int count = 0;
  for (int i = 0; i < p.length; i++) {
    if (p[i] < p[i - 1]) {
      count++;
    }
  }
  if (count > 1) {
    throw "FloatMapping - Progress wraps more than once: ${p.join(",")}";
  }
}
