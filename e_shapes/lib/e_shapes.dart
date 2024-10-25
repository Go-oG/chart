library;

import 'dart:math' as m;

import 'package:e_shapes/src/corner_rounding.dart';
import 'package:e_shapes/src/round_polygon.dart';
import 'package:e_shapes/src/utils.dart';
import 'src/point.dart';

export 'src/corner_rounding.dart';
export 'src/cubic.dart';
export "src/round_polygon.dart";
export "src/features.dart" hide Edge, Corner;

export "src/morph.dart";
export "src/pair.dart";

RoundedPolygon circle({
  int numVertices = 8,
  double radius = 1,
  double centerX = 0,
  double centerY = 0,
}) {
  if (numVertices < 3) throw ("Circle must have at least three vertices");

  var theta = m.pi / numVertices;
  var polygonRadius = radius / m.cos(theta);
  return RoundedPolygon.of(numVertices,
      rounding: CornerRounding(radius), radius: polygonRadius, centerX: centerX, centerY: centerY);
}

RoundedPolygon rectangle(
    {double width = 2,
      double height = 2,
      CornerRounding rounding = CornerRounding.unRounded,
      List<CornerRounding>? perVertexRounding,
      double centerX = 0,
      double centerY = 0}) {
  var left = centerX - width / 2;
  var top = centerY - height / 2;
  var right = centerX + width / 2;
  var bottom = centerY + height / 2;
  return RoundedPolygon.of2(
    [right, bottom, left, bottom, left, top, right, top],
    rounding: rounding,
    perVertexRounding: perVertexRounding,
    centerX: centerX,
    centerY: centerY,
  );
}

RoundedPolygon star({
  int numVerticesPerRadius = 1,
  double radius = 1,
  double innerRadius = 0.5,
  CornerRounding rounding = CornerRounding.unRounded,
  CornerRounding? innerRounding,
  List<CornerRounding>? perVertexRounding,
  double centerX = 0,
  double centerY = 0,
}) {
  if (radius <= 0 || innerRadius <= 0) {
    throw ("Star radii must both be greater than 0");
  }
  if (innerRadius >= radius) {
    throw ("innerRadius must be less than radius");
  }
  List<CornerRounding>? pvRounding = perVertexRounding;
  if (pvRounding == null && innerRounding != null) {
    pvRounding = [];
    for (var i = 0; i < numVerticesPerRadius; i++) {
      pvRounding.add(rounding);
      pvRounding.add(innerRounding);
    }
  }
  return RoundedPolygon.of2(
    _starVerticesFromNumVerts(numVerticesPerRadius, radius, innerRadius, centerX, centerY),
    rounding: rounding,
    perVertexRounding: pvRounding,
    centerX: centerX,
    centerY: centerY,
  );
}

RoundedPolygon pill({
  double width = 2,
  double height = 1,
  double smoothing = 0,
  double centerX = 0,
  double centerY = 0,
}) {
  if (width <= 0 && height <= 0) {
    throw ("Pill shapes must have positive width and height");
  }
  var wHalf = width / 2;
  var hHalf = height / 2;
  return RoundedPolygon.of2([
    wHalf + centerX,
    hHalf + centerY,
    -wHalf + centerX,
    hHalf + centerY,
    -wHalf + centerX,
    -hHalf + centerY,
    wHalf + centerX,
    -hHalf + centerY,
  ], rounding: CornerRounding(m.min(wHalf, hHalf), smoothing), centerX: centerX, centerY: centerY);
}

RoundedPolygon pillStar(
    {double width = 2,
      double height = 1,
      int numVerticesPerRadius = 8,
      double innerRadiusRatio = 0.5,
      CornerRounding rounding = CornerRounding.unRounded,
      CornerRounding? innerRounding,
      List<CornerRounding>? perVertexRounding,
      double vertexSpacing = 0.5,
      double startLocation = 0,
      double centerX = 0,
      double centerY = 0}) {
  if (width <= 0 && height <= 0) {
    throw ("Pill shapes must have positive width and height");
  }
  if (innerRadiusRatio <= 0 || innerRadiusRatio > 1) {
    throw ("innerRadius must be between 0 and 1");
  }
  var pvRounding = perVertexRounding;
  if (pvRounding == null && innerRounding != null) {
    pvRounding = [];
    for (int i = 0; i < numVerticesPerRadius; i++) {
      pvRounding.add(rounding);
      pvRounding.add(innerRounding);
    }
  }
  return RoundedPolygon.of2(
    _pillStarVerticesFromNumVerts(
        numVerticesPerRadius, width, height, innerRadiusRatio, vertexSpacing, startLocation, centerX, centerY),
    rounding: rounding,
    perVertexRounding: pvRounding,
    centerX: centerX,
    centerY: centerY,
  );
}

List<double> _pillStarVerticesFromNumVerts(
    int numVerticesPerRadius,
    double width,
    double height,
    double innerRadius,
    double vertexSpacing,
    double startLocation,
    double centerX,
    double centerY,
    ) {
  var endcapRadius = m.min(width, height);
  var vSegLen = (height - width).coerceAtLeast(0);
  var hSegLen = (width - height).coerceAtLeast(0);
  var vSegHalf = vSegLen / 2;
  var hSegHalf = hSegLen / 2;

  var circlePerimeter = twoPi * endcapRadius * interpolate(innerRadius, 1, vertexSpacing);
  var perimeter = 2 * hSegLen + 2 * vSegLen + circlePerimeter;

  List<double> sections = List.filled(11, 0, growable: true);
  sections[0] = 0;
  sections[1] = vSegLen / 2;
  sections[2] = sections[1] + circlePerimeter / 4;
  sections[3] = sections[2] + hSegLen;
  sections[4] = sections[3] + circlePerimeter / 4;
  sections[5] = sections[4] + vSegLen;
  sections[6] = sections[5] + circlePerimeter / 4;
  sections[7] = sections[6] + hSegLen;
  sections[8] = sections[7] + circlePerimeter / 4;
  sections[9] = sections[8] + vSegLen / 2;
  sections[10] = perimeter;

  var tPerVertex = perimeter / (2 * numVerticesPerRadius);
  var inner = false;
  int currSecIndex = 0;
  double secStart = 0;
  var secEnd = sections[1];
  var t = startLocation * perimeter;

  List<double> result = List.filled(numVerticesPerRadius * 4, 0);
  var arrayIndex = 0;
  var rectBR = Point(hSegHalf, vSegHalf);
  var rectBL = Point(-hSegHalf, vSegHalf);
  var rectTL = Point(-hSegHalf, -vSegHalf);
  var rectTR = Point(hSegHalf, -vSegHalf);

  for (int i = 0; i < numVerticesPerRadius * 2; i++) {
    var boundedT = t % perimeter;
    if (boundedT < secStart) {
      currSecIndex = 0;
    }
    while (boundedT >= sections[(currSecIndex + 1) % sections.length]) {
      currSecIndex = (currSecIndex + 1) % sections.length;
      secStart = sections[currSecIndex];
      secEnd = sections[(currSecIndex + 1) % sections.length];
    }

    var tInSection = boundedT - secStart;
    var tProportion = tInSection / (secEnd - secStart);
    var currRadius = (inner) ? (endcapRadius * innerRadius) : endcapRadius;
    Point vertex;

    switch (currSecIndex) {
      case 0:
        vertex = Point(currRadius, tProportion * vSegHalf);
        break;
      case 1:
        vertex = radialToCartesian(currRadius, tProportion * m.pi / 2) + rectBR;
        break;
      case 2:
        vertex = Point(hSegHalf - tProportion * hSegLen, currRadius);
        break;
      case 3:
        vertex = radialToCartesian(currRadius, m.pi / 2 + (tProportion * m.pi / 2)) + rectBL;
        break;
      case 4:
        vertex = Point(-currRadius, vSegHalf - tProportion * vSegLen);
        break;
      case 5:
        vertex = radialToCartesian(currRadius, m.pi + (tProportion * m.pi / 2)) + rectTL;
        break;
      case 6:
        vertex = Point(-hSegHalf + tProportion * hSegLen, -currRadius);
        break;
      case 7:
        vertex = radialToCartesian(currRadius, m.pi * 1.5 + (tProportion * m.pi / 2)) + rectTR;
        break;
      default:
        vertex = Point(currRadius, -vSegHalf + tProportion * vSegHalf);
    }
    result[arrayIndex++] = vertex.x + centerX;
    result[arrayIndex++] = vertex.y + centerY;
    t += tPerVertex;
    inner = !inner;
  }
  return result;
}

List<double> _starVerticesFromNumVerts(
    int numVerticesPerRadius, double radius, double innerRadius, double centerX, double centerY) {
  List<double> result = List.filled(numVerticesPerRadius * 4, 0);
  int arrayIndex = 0;
  for (int i = 0; i < numVerticesPerRadius; i++) {
    var vertex = radialToCartesian(radius, (m.pi / numVerticesPerRadius * 2 * i));
    result[arrayIndex++] = vertex.x + centerX;
    result[arrayIndex++] = vertex.y + centerY;
    vertex = radialToCartesian(innerRadius, (m.pi / numVerticesPerRadius * (2 * i + 1)));
    result[arrayIndex++] = vertex.x + centerX;
    result[arrayIndex++] = vertex.y + centerY;
  }
  return result;
}

class TransformResult {
  final double first;
  final double second;

  TransformResult(this.first, this.second);
}

typedef PointTransformer = TransformResult Function(double x, double y);

