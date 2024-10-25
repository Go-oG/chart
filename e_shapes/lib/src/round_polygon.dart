import 'dart:math' as m;
import 'dart:math';
import 'dart:ui';

import 'package:e_shapes/src/pair.dart';
import 'package:e_shapes/src/utils.dart' as util;
import 'package:flutter/foundation.dart';

import '../e_shapes.dart';
import 'features.dart';
import 'point.dart';

class RoundedPolygon {
  final List<Feature> features;
  final double centerX;
  final double centerY;
  late List<Cubic> cubics;

  RoundedPolygon(this.features, this.centerX, this.centerY) {
    cubics = [];
    Cubic? firstCubic;
    Cubic? lastCubic;
    List<Cubic>? firstFeatureSplitStart;
    List<Cubic>? firstFeatureSplitEnd;
    if (features.isNotEmpty && features[0].cubics.length == 3) {
      var centerCubic = features[0].cubics[1];
      List<Cubic> tmp = centerCubic.split(0.5);

      firstFeatureSplitStart = [features[0].cubics[0], tmp.first];
      firstFeatureSplitEnd = [tmp[1], features[0].cubics[2]];
    }
    for (int i = 0; i <= features.length; i++) {
      List<Cubic> featureCubics;

      if (i == 0 && firstFeatureSplitEnd != null) {
        featureCubics = firstFeatureSplitEnd;
      } else if (i == features.length) {
        if (firstFeatureSplitStart != null) {
          featureCubics = firstFeatureSplitStart;
        } else {
          break;
        }
      } else {
        featureCubics = features[i].cubics;
      }

      for (var (j, _) in featureCubics.indexed) {
        var cubic = featureCubics[j];
        if (!cubic.zeroLength()) {
          if (lastCubic != null) cubics.add(lastCubic);
          lastCubic = cubic;
          firstCubic ??= cubic;
        } else {
          if (lastCubic != null) {
            lastCubic = Cubic.fromList(lastCubic.points.toList());
            lastCubic.points[6] = cubic.anchor1X;
            lastCubic.points[7] = cubic.anchor1Y;
          }
        }
      }
    }
    if (lastCubic != null && firstCubic != null) {
      cubics.add(Cubic(lastCubic.anchor0X, lastCubic.anchor0Y, lastCubic.control0X, lastCubic.control0Y,
          lastCubic.control1X, lastCubic.control1Y, firstCubic.anchor0X, firstCubic.anchor0Y));
    } else {
      cubics.add(Cubic(centerX, centerY, centerX, centerY, centerX, centerY, centerX, centerY));
    }
    _init();
  }

  factory RoundedPolygon.of(
    int numVertices, {
    double radius = 1,
    double centerX = 0,
    double centerY = 0,
    CornerRounding rounding = CornerRounding.unRounded,
    List<CornerRounding>? perVertexRounding,
  }) {
    return RoundedPolygon.of2(_verticesFromNumVerts(numVertices, radius, centerX, centerY),
        rounding: rounding, perVertexRounding: perVertexRounding, centerX: centerX, centerY: centerY);
  }

  factory RoundedPolygon.of2(
    List<double> vertices, {
    CornerRounding rounding = CornerRounding.unRounded,
    List<CornerRounding>? perVertexRounding,
    double centerX = double.minPositive,
    double centerY = double.minPositive,
  }) {
    if (vertices.length < 6) {
      throw "Polygons must have at least 3 vertices";
    }
    if (vertices.length % 2 == 1) {
      throw "The vertices array should have even size";
    }
    if (perVertexRounding != null && perVertexRounding.length * 2 != vertices.length) {
      throw "perVertexRounding list should be either null or the same size as the number of vertices (vertices.size / 2)";
    }
    List<List<Cubic>> corners = [];
    int n = vertices.length ~/ 2;
    List<RoundedCorner> roundedCorners = [];
    for (int i = 0; i < n; i++) {
      var vtxRounding = perVertexRounding?[i] ?? rounding;
      var prevIndex = ((i + n - 1) % n) * 2;
      var nextIndex = ((i + 1) % n) * 2;
      roundedCorners.add(RoundedCorner(
          Point(vertices[prevIndex], vertices[prevIndex + 1]),
          Point(vertices[i * 2], vertices[i * 2 + 1]),
          Point(vertices[nextIndex], vertices[nextIndex + 1]),
          vtxRounding));
    }

    List<Pair<double, double>> cutAdjusts = List.generate(n, (e) => e).map<Pair<double, double>>((ix) {
      var expectedRoundCut = roundedCorners[ix].expectedRoundCut + roundedCorners[(ix + 1) % n].expectedRoundCut;
      var expectedCut = roundedCorners[ix].expectedCut + roundedCorners[(ix + 1) % n].expectedCut;
      var vtxX = vertices[ix * 2];
      var vtxY = vertices[ix * 2 + 1];
      var nextVtxX = vertices[((ix + 1) % n) * 2];
      var nextVtxY = vertices[((ix + 1) % n) * 2 + 1];
      var sideSize = util.distance(vtxX - nextVtxX, vtxY - nextVtxY);
      if (expectedRoundCut > sideSize) {
        return Pair(sideSize / expectedRoundCut, 0);
      }
      if (expectedCut > sideSize) {
        return Pair(1, (sideSize - expectedRoundCut) / (expectedCut - expectedRoundCut));
      }
      return Pair(1, 1);
    }).toList();

    for (int i = 0; i < n; i++) {
      List<double> allowedCuts = [0, 0];
      for (int delta = 0; delta <= 1; delta++) {
        var tmp = cutAdjusts[(i + n - 1 + delta) % n];
        var roundCutRatio = tmp.first;
        var cutRatio = tmp.second;
        allowedCuts.add(roundedCorners[i].expectedRoundCut * roundCutRatio +
            (roundedCorners[i].expectedCut - roundedCorners[i].expectedRoundCut) * cutRatio);
      }
      corners.add(roundedCorners[i].getCubics(allowedCuts[0], allowedCuts[1]));
    }

    List<Feature> tempFeatures = [];
    for (int i = 0; i < n; i++) {
      var prevVtxIndex = (i + n - 1) % n;
      var nextVtxIndex = (i + 1) % n;
      var currVertex = Point(vertices[i * 2], vertices[i * 2 + 1]);
      var prevVertex = Point(vertices[prevVtxIndex * 2], vertices[prevVtxIndex * 2 + 1]);
      var nextVertex = Point(vertices[nextVtxIndex * 2], vertices[nextVtxIndex * 2 + 1]);
      bool convex = util.convex(prevVertex, currVertex, nextVertex);
      tempFeatures.add(Corner(corners[i], convex));
      tempFeatures.add(Edge([
        Cubic.straightLine(corners[i].last.anchor1X, corners[i].last.anchor1Y, corners[(i + 1) % n].first.anchor0X,
            corners[(i + 1) % n].first.anchor0Y)
      ]));
    }

    double cx;
    double cy;

    if (centerX == double.minPositive || centerY == double.minPositive) {
      var p = _calculateCenter(vertices);
      cx = p.x;
      cy = p.y;
    } else {
      cx = centerX;
      cy = centerY;
    }
    return RoundedPolygon(tempFeatures, cx, cy);
  }

  _init() {
    var prevCubic = cubics[cubics.length - 1];
    for (var (index, _) in cubics.indexed) {
      var cubic = cubics[index];
      if ((cubic.anchor0X - prevCubic.anchor1X).abs() > util.distanceEpsilon ||
          (cubic.anchor0Y - prevCubic.anchor1Y).abs() > util.distanceEpsilon) {
        throw "RoundedPolygon must be contiguous, with the anchor points of all curves matching the anchor points of the preceding and succeeding cubics";
      }
      prevCubic = cubic;
    }
  }

  RoundedPolygon copy() {
    return RoundedPolygon(this.features, centerX, centerY);
  }

  RoundedPolygon transformed(PointTransformer f) {
    var center = Point(centerX, centerY).transformed(f);
    List<Feature> list = [];

    for (var (i, _) in features.indexed) {
      list.add(features[i].transformed(f));
    }
    return RoundedPolygon(list, center.x, center.y);
  }

  RoundedPolygon normalized() {
    var bounds = calculateBounds();
    var width = bounds[2] - bounds[0];
    var height = bounds[3] - bounds[1];
    var side = m.max(width, height);

    var offsetX = (side - width) / 2 - bounds[0];
    var offsetY = (side - height) / 2 - bounds[1];
    return transformed((x, y) {
      return TransformResult((x + offsetX) / side, (y + offsetY) / side);
    });
  }

  List<double> calculateMaxBounds([List<double>? bounds]) {
    bounds ??= List.filled(4, 0, growable: true);

    if (bounds.length < 4) {
      throw "Required bounds size of 4";
    }

    double maxDistSquared = 0;
    for (var (i, _) in cubics.indexed) {
      var cubic = cubics[i];
      var anchorDistance = util.distanceSquared(cubic.anchor0X - centerX, cubic.anchor0Y - centerY);
      var middlePoint = cubic.pointOnCurve(0.5);
      var middleDistance = util.distanceSquared(middlePoint.x - centerX, middlePoint.y - centerY);
      maxDistSquared = max(maxDistSquared, max(anchorDistance, middleDistance));
    }
    var distance = sqrt(maxDistSquared);
    bounds[0] = centerX - distance;
    bounds[1] = centerY - distance;
    bounds[2] = centerX + distance;
    bounds[3] = centerY + distance;
    return bounds;
  }

  List<double> calculateBounds([List<double>? bounds, bool approximate = true]) {
    bounds ??= List.filled(4, 0, growable: true);
    if (bounds.length < 4) {
      throw "Required bounds size of 4";
    }

    var minX = double.maxFinite;
    var minY = double.maxFinite;
    var maxX = double.minPositive;
    var maxY = double.minPositive;
    for (var (i, _) in cubics.indexed) {
      var cubic = cubics[i];
      cubic.calculateBounds(bounds, approximate = approximate);
      minX = min(minX, bounds[0]);
      minY = min(minY, bounds[1]);
      maxX = max(maxX, bounds[2]);
      maxY = max(maxY, bounds[3]);
    }
    bounds[0] = minX;
    bounds[1] = minY;
    bounds[2] = maxX;
    bounds[3] = maxY;
    return bounds;
  }

  Path toPath([Path? path]) {
    return util.toPath(path ?? Path(), cubics);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    return other is RoundedPolygon && listEquals(features, other.features);
  }

  @override
  int get hashCode {
    return Object.hashAll(features);
  }
}

class RoundedCorner {
  final Point p0;
  final Point p1;
  final Point p2;
  final CornerRounding? rounding;

  late final Point d1;
  late final Point d2;
  late final double cornerRadius;
  late final double smoothing;
  late final double cosAngle;
  late final double sinAngle;
  late final double expectedRoundCut;

  RoundedCorner(this.p0, this.p1, this.p2, [this.rounding]) {
    var v01 = p0 - p1;
    var v21 = p2 - p1;
    var d01 = v01.distance;
    var d21 = v21.distance;
    if (d01 > 0 && d21 > 0) {
      d1 = v01.div(d01);
      d2 = v21.div(d21);
      cornerRadius = rounding?.radius ?? 0;
      smoothing = rounding?.smoothing ?? 0;
      cosAngle = d1.dotProduct(d2);
      sinAngle = sqrt(1 - util.square(cosAngle));
      if (sinAngle > 1e-3) {
        expectedRoundCut = cornerRadius * (cosAngle + 1) / sinAngle;
      } else {
        expectedRoundCut = 0;
      }
    } else {
      d1 = Point(0, 0);
      d2 = Point(0, 0);
      cornerRadius = 0;
      smoothing = 0;
      cosAngle = 0;
      sinAngle = 0;
      expectedRoundCut = 0;
    }
  }

  double get expectedCut {
    return (1 + smoothing) * expectedRoundCut;
  }

  Point center = Point(0, 0);

  List<Cubic> getCubics(double allowedCut0, [double? allowedCut1]) {
    allowedCut1 ??= allowedCut0;
    var allowedCut = min(allowedCut0, allowedCut1);
    if (expectedRoundCut < util.distanceEpsilon ||
        allowedCut < util.distanceEpsilon ||
        cornerRadius < util.distanceEpsilon) {
      center = p1;
      return [Cubic.straightLine(p1.x, p1.y, p1.x, p1.y)];
    }

    var actualRoundCut = min(allowedCut, expectedRoundCut);
    var actualSmoothing0 = _calculateActualSmoothingValue(allowedCut0);
    var actualSmoothing1 = _calculateActualSmoothingValue(allowedCut1);
    var actualR = cornerRadius * actualRoundCut / expectedRoundCut;

    var centerDistance = sqrt(util.square(actualR) + util.square(actualRoundCut));

    center = p1 + ((d1 + d2).div(2)).direction.mul(centerDistance);
    var circleIntersection0 = p1 + d1.mul(actualRoundCut);
    var circleIntersection2 = p1 + d2.mul(actualRoundCut);
    var flanking0 = _computeFlankingCurve(
        actualRoundCut, actualSmoothing0, p1, p0, circleIntersection0, circleIntersection2, center, actualR);
    var flanking2 = _computeFlankingCurve(
            actualRoundCut, actualSmoothing1, p1, p2, circleIntersection2, circleIntersection0, center, actualR)
        .reverse;
    return [
      flanking0,
      Cubic.circularArc(
          center.x, center.y, flanking0.anchor1X, flanking0.anchor1Y, flanking2.anchor0X, flanking2.anchor0Y),
      flanking2
    ];
  }

  double _calculateActualSmoothingValue(double allowedCut) {
    if (allowedCut > expectedCut) {
      return smoothing;
    }
    if (allowedCut > expectedRoundCut) {
      return smoothing * (allowedCut - expectedRoundCut) / (expectedCut - expectedRoundCut);
    }
    return 0;
  }

  Cubic _computeFlankingCurve(double actualRoundCut, double actualSmoothingValues, Point corner, Point sideStart,
      Point circleSegmentIntersection, Point otherCircleSegmentIntersection, Point circleCenter, double actualR) {
    var sideDirection = (sideStart - corner).direction;
    var curveStart = corner + sideDirection.mul(actualRoundCut).mul(1 + actualSmoothingValues);

    Point p = Point.interpolate(circleSegmentIntersection,
        (circleSegmentIntersection + otherCircleSegmentIntersection).div(2), actualSmoothingValues);

    var curveEnd = circleCenter + util.directionVector(p.x - circleCenter.x, p.y - circleCenter.y).mul(actualR);

    var circleTangent = (curveEnd - circleCenter).rotate90();
    Point anchorEnd = lineIntersection(sideStart, sideDirection, curveEnd, circleTangent) ?? circleSegmentIntersection;

    Point anchorStart = (curveStart + anchorEnd.mul(2)).div(3);
    return Cubic.of(curveStart, anchorStart, anchorEnd, curveEnd);
  }

  Point? lineIntersection(Point p0, Point d0, Point p1, Point d1) {
    var rotatedD1 = d1.rotate90();
    var den = d0.dotProduct(rotatedD1);
    if (den.abs() < util.distanceEpsilon) return null;
    var num = (p1 - p0).dotProduct(rotatedD1);

    if (den.abs() < util.distanceEpsilon * num.abs()) return null;
    var k = num / den;
    return p0 + d0.mul(k);
  }
}

Point _calculateCenter(List<double> vertices) {
  double cumulativeX = 0;
  double cumulativeY = 0;
  int index = 0;
  while (index < vertices.length) {
    cumulativeX += vertices[index++];
    cumulativeY += vertices[index++];
  }
  return Point(cumulativeX / (vertices.length / 2), cumulativeY / (vertices.length / 2));
}

List<double> _verticesFromNumVerts(int numVertices, double radius, double centerX, double centerY) {
  List<double> result = List.filled(numVertices * 2, 0);
  var arrayIndex = 0;
  for (int i = 0; i < numVertices; i++) {
    var vertex = util.radialToCartesian(radius, (m.pi / numVertices * 2 * i)) + Point(centerX, centerY);
    result[arrayIndex++] = vertex.x;
    result[arrayIndex++] = vertex.y;
  }
  return result;
}
