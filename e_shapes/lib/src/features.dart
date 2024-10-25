import 'dart:core';

import '../e_shapes.dart';
import 'cubic.dart';

abstract class Feature {
  final List<Cubic> cubics;

  Feature(this.cubics);

  Feature transformed(PointTransformer f);

  Feature reversed();
}

class Edge extends Feature {
  Edge(super.cubic);

  @override
  Edge transformed(PointTransformer f) {
    List<Cubic> list = [];
    for (var item in cubics) {
      list.add(item.transformed(f));
    }
    return Edge(list);
  }

  @override
  Edge reversed() {
    List<Cubic> reversedCubics = [];
    for (int i = cubics.length - 1; i >= 0; i--) {
      reversedCubics.add(cubics[i].reverse);
    }
    return Edge(reversedCubics);
  }
}

class Corner extends Feature {
  final bool convex;

  Corner(super.cubics, [this.convex = true]);

  @override
  Feature transformed(PointTransformer f) {
    List<Cubic> list = [];
    for (var item in cubics) {
      list.add(item.transformed(f));
    }
    return Corner(list, convex);
  }

  @override
  Corner reversed() {
    List<Cubic> reversedCubics = [];
    for (int i = cubics.length - 1; i >= 0; i--) {
      reversedCubics.add(cubics[i].reverse);
    }
    return Corner(reversedCubics, !convex);
  }
}
