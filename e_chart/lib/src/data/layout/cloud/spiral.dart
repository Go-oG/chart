import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/index.dart';

import 'helper.dart';

/// 根据螺旋线迭代取得一个位置
/// return [x,y]
Point2? iterate(
  TwoDimArray dist,
  Point2 startPoint,
  Point2 pos,
  num canvasWidth,
  num canvasHeight,
) {
  // m 控制螺旋线在法向上的前进速度
  // dEta 控制螺旋线在当前距离场方向的切线方向的前进速度
  const m = 0.7, dEta = pi / 10;
  List<num> point = [pos.x, pos.y];

  // 距中心的半径 r
  num r = startPoint.distance(pos);
  // 法线
  var normal = _computeSDF(dist, point[0], point[1]);

  normal = Point2(-normal.x, -normal.y);
  var normalLen = _norm(normal.x, normal.y);
  // 切线
  var tangent = [-normal.y, normal.x];
  // 黑塞矩阵是为了计算距离场中某点的曲率
  List<num> hessian = _computeHessian(dist, point[0], point[1]);
  var tem = [
    tangent[0] * hessian[0] + tangent[1] * hessian[1],
    tangent[0] * hessian[1] + tangent[1] * hessian[2],
  ];
  var temValue = tangent[0] * tem[0] + tangent[1] * tem[1];
  var curvature = max(temValue / (normalLen * normalLen * normalLen), 0.001);
  // 曲率半径 R
  var R = (1 / curvature).abs();

  var dTheta = (R * dEta) / r;
  dTheta = dTheta / pi / 100;
  // tangent 方向的位移
  var maxTS = 1.2, minTS = 1;
  var dTangent = [r * dTheta * (tangent[0] / normalLen), r * dTheta * (tangent[1] / normalLen)];
  var normDT = _norm(dTangent.first, dTangent.last);
  // 调整tangent方向的位移
  if (normDT > maxTS) {
    dTangent = [(maxTS / normDT) * dTangent[0], (maxTS / normDT) * dTangent[1]];
  }
  if (_norm(dTangent.first, dTangent.last) < minTS) {
    dTangent = [(tangent[0] * 2) / normalLen, (tangent[1] * 2) / normalLen];
  }

  // normal 方向位移
  var dNormal = [m * dTheta * (normal.x / normalLen), m * dTheta * (normal.y / normalLen)];

  var dx = dNormal[0] + dTangent[0];
  var dy = dNormal[1] + dTangent[1];
  point[0] += dx;
  point[1] += dy;

  // 检测是否出界
  if (point[0] != 0 && point[1] != 0) {
    if (dist.get(point[0].floor(), point[1].floor()) <= 0) {
      return null;
    }
    if (point[0] > canvasWidth - 2 || point[0] < 2) {
      return null;
    }
    if (point[1] > canvasHeight - 2 || point[1] < 2) {
      return null;
    }
  } else {
    return null;
  }
  return Point2(point[0], point[1]);
}

/// return[x,y]
Point2 _computeSDF(TwoDimArray dist, num px, num py) {
// 计算signed distance field相关信息，得到当前点的梯度方向
  List<num> wordPosition = [px.floor(), py.floor()];
  const kernelSize = 3;
  var offset = (kernelSize / 2).floor();

  ///[x,y]
  Point2 localGrad = Point2(0, 0);
  const gradX = [
    [1, 2, 1],
    [0, 0, 0],
    [-1, -2, -1],
  ];
  const gradY = [
    [1, 0, -1],
    [2, 0, -2],
    [1, 0, -1],
  ];

  for (var i = 0; i < kernelSize; i++) {
    for (var j = 0; j < kernelSize; j++) {
      var offsetX = i - offset, offsetY = j - offset;
      var local = -dist.get(wordPosition[0] + offsetX, wordPosition[1] + offsetY);
      localGrad.x += local * gradX[i][j];
      localGrad.y += local * gradY[i][j];
    }
  }
  return localGrad;
}

///[xx,xy,yy]
List<num> _computeHessian(TwoDimArray dist, num px, num py) {
  // Hessian 矩阵, 用于描述函数局部的曲率
  var wordPosition = [px.floor(), py.floor()];
  const kernelSize = 3;
  var offset = (kernelSize / 2).floor();
  const gradX = [
    [1, 2, 1],
    [0, 0, 0],
    [-1, -2, -1],
  ];
  const gradY = [
    [1, 0, -1],
    [2, 0, -2],
    [1, 0, -1],
  ];

//{ xx: 0, xy: 0, yy: 0 }
  List<num> localHessian = [0, 0, 0];

  for (var i = 0; i < kernelSize; i++) {
    for (var j = 0; j < kernelSize; j++) {
      var offsetX = i - offset, offsetY = j - offset;
      var localGrad = _computeSDF(dist, wordPosition[0] + offsetX, wordPosition[1] + offsetY);
      localHessian[0] += localGrad.x * gradX[i][j];
      localHessian[1] += localGrad.x * gradY[i][j];
      localHessian[2] += localGrad.y * gradY[i][j];
    }
  }
  return localHessian;
}

num _norm(num x, num y) {
  return sqrt(x * x + y * y);
}
