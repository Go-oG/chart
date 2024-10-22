import 'dart:math';

import 'package:e_chart/e_chart.dart';

class TidyData {
  TreeNode? threadLeft;
  TreeNode? threadRight;
  TreeNode? extremeLeft;
  TreeNode? extremeRight;
  double shiftAcceleration;

  /// Cached change of x position
  double shiftChange;

  /// this.x = parent.x + modifier_to_subtree
  double modifierToSubtree;

  /// this.x + modifier_thread_left == thread_left.x
  double modifierThreadLeft;

  /// this.x + modifier_thread_right == thread_right.x
  double modifierThreadRight;

  /// this.x + modifier_extreme_left == extreme_left.x
  double modifierExtremeLeft;

  /// this.x + modifier_extreme_right == extreme_right.x
  double modifierExtremeRight;

  TidyData({
    this.threadLeft,
    this.threadRight,
    this.extremeLeft,
    this.extremeRight,
    this.shiftAcceleration = 0,
    this.shiftChange = 0,
    this.modifierToSubtree = 0,
    this.modifierThreadLeft = 0,
    this.modifierThreadRight = 0,
    this.modifierExtremeLeft = 0,
    this.modifierExtremeRight = 0,
  });
}

final class TidyPosResult{
  final String id;
  final double x;
  final double y;

  const TidyPosResult(this.id, this.x, this.y);

  @override
  String toString() {
    return "$id:[$x,$y]";
  }
}

class TidyPoint {
  late double x;
  late double y;

  static TidyOrientation orientation(TidyPoint p, TidyPoint q, TidyPoint r) {
    var val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);

    if (val.abs() < 1e-7) {
      return TidyOrientation.colinear;
    }
    if (val > 0) {
      return TidyOrientation.clockWise;
    }
    return TidyOrientation.counterClockWise;
  }

  @override
  int get hashCode {
    return Object.hash(x, y);
  }

  @override
  bool operator ==(Object other) {
    return other is TidyPoint && other.x == x && other.y == y;
  }
}

enum TidyOrientation {
  clockWise,
  counterClockWise,
  colinear;
}

class TidyLine {
  late TidyPoint from;
  late TidyPoint to;

  bool isPointOnLineIfColinear(TidyPoint point) {
    return point.x >= min(from.x, to.x) &&
        point.x <= max(from.x, to.x) &&
        point.y >= min(from.y, to.y) &&
        point.y <= max(from.y, to.y);
  }

  bool intersect(TidyLine other) {
    var o1 = TidyPoint.orientation(from, to, other.from);
    var o2 = TidyPoint.orientation(from, to, other.to);
    var o3 = TidyPoint.orientation(other.from, other.to, from);
    var o4 = TidyPoint.orientation(other.from, other.to, to);
    if (o1 != o2 && o3 != o4) {
      return true;
    }

    if (o1 == TidyOrientation.colinear && isPointOnLineIfColinear(other.from)) {
      return true;
    }
    if (o2 == TidyOrientation.colinear && isPointOnLineIfColinear(other.to)) {
      return true;
    }
    if (o3 == TidyOrientation.colinear && other.isPointOnLineIfColinear(from)) {
      return true;
    }
    if (o4 == TidyOrientation.colinear && other.isPointOnLineIfColinear(to)) {
      return true;
    }

    return false;
  }

  bool connectedTo(TidyLine other) {
    return from == other.from || from == other.to || to == other.from || to == other.to;
  }

  @override
  int get hashCode {
    return Object.hash(from, to);
  }

  @override
  bool operator ==(Object other) {
    return other is TidyLine && other.from == from && other.to == to;
  }
}
