import 'dart:math';

class TwoDimArray {
  int width;
  int height;
  late List<num> array;

  TwoDimArray(this.width, this.height, [num fillValue = 0]) {
    array = List.filled(width * height, fillValue);
  }

  num get(num x, num y) {
    return array[y.floor() * width + x.floor()];
  }

  void set(num x, num y, num value) {
    array[y.floor() * width + x.floor()] = value;
  }

  List<num> getShape() {
    return [width, height];
  }

  void fromArray(List<List<num>> array) {
    for (var y = 0; y < array.length; y++) {
      for (var x = 0; x < array[y].length; x++) {
        this.array[y * width + x] = array[y][x];
      }
    }
  }

  List<List<num>> toArray() {
    List<List<num>> result = [];
    for (var y = 0; y < height; y++) {
      List<num> tl = [];
      result.add(tl);
      for (var x = 0; x < width; x++) {
        tl.add(array[y * width + x]);
      }
    }
    return result;
  }
}

num calDistance(List<num> p1, List<num> p2) {
  return sqrt((p1[0] - p2[0]) * (p1[0] - p2[0]) + (p1[1] - p2[1]) * (p1[1] - p2[1]));
}
