import 'cubic.dart';
import 'features.dart';

List<Feature> detectFeatures(List<Cubic> cubics) {
  if (cubics.isEmpty) {
    return [];
  }
  List<Feature> list = [];
  var current = cubics.first;
  for (var (i, v) in cubics.indexed) {
    var next = cubics[(i + 1) % (cubics.length)];
    if (i < cubics.length - 1 && current.alignsIshWith(next)) {
      current = Cubic.extend(current, next);
      continue;
    }
    list.add(current.asFeature(next));
    if (!current.smoothesIntoIsh(next)) {
      list.add(Cubic.empty(current.anchor1X, current.anchor1Y).asFeature(next));
    }
    current = next;
  }
  return list;
}
