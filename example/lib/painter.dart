import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:e_paths/e_paths.dart';
import 'package:flutter/material.dart' as mat;

class MyPainter extends mat.CustomPainter {
  final mat.AnimationController controller;
  final mat.Paint mPaint = mat.Paint();
  Path p1 = Path();

  Path p2 = Path();
  late PathMorph morph;
  bool _init = false;

  MyPainter(this.controller) : super(repaint: controller) {
    mPaint.style = PaintingStyle.fill;
    mPaint.strokeWidth = 2;
    mPaint.color = mat.Colors.black87;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _initIfNeed(size);
    // mPaint.style = PaintingStyle.stroke;
    // mPaint.color = mat.Colors.black87;
    // mPaint.strokeWidth = 2;
    // var rect = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width, height: size.height);
    // canvas.drawLine(rect.centerLeft, rect.centerRight, mPaint);
    // canvas.drawLine(rect.topCenter, rect.bottomCenter, mPaint);
    //
    // mPaint.color = mat.Colors.blueAccent;
    // canvas.drawPath(p1.rawPath, mPaint);

    // mPaint.color = mat.Colors.deepPurple;
    // canvas.drawPath(p2.rawPath, mPaint);

    //  mPaint.style = PaintingStyle.stroke;

    // for (var item in p1.pickSegment()) {
    //   for (var tt in item) {
    //     for (var cubic in tt) {
    //       ui.Path tmpPath = ui.Path();
    //       tmpPath.moveTo(cubic.start.dx, cubic.start.dy);
    //       tmpPath.cubicTo(
    //         cubic.c1.dx,
    //         cubic.c1.dy,
    //         cubic.c2.dx,
    //         cubic.c2.dy,
    //         cubic.end.dx,
    //         cubic.end.dy,
    //       );
    //       canvas.drawPath(tmpPath, mPaint);
    //       canvas.drawCircle(cubic.start, 6, mPaint);
    //       canvas.drawCircle(cubic.c1, 6, mPaint);
    //       canvas.drawCircle(cubic.c2, 6, mPaint);
    //       canvas.drawCircle(cubic.end, 6, mPaint);
    //     }
    //   }
    // }
    //
    // for (var item in morph.getControlPoints(true)) {
    //   mPaint.color = randomColor();
    //   for (var cc in item) {
    //     canvas.drawCircle(cc, 6, mPaint);
    //   }
    //   break;
    // }

    // mPaint.color = mat.Colors.red;
    // for (var item in morph.getControlPoints(false)) {
    //   for (var offset in item) {
    //     canvas.drawCircle(offset, 6, mPaint);
    //   }
    // }
    // mPaint.style = PaintingStyle.stroke;
    //
 //   canvas.drawPath(morph.lerp(controller.value, true), mPaint);
    drawArc(canvas);
  }

  void _initIfNeed(Size size) {
    if (_init) {
      return;
    }
    _init = true;
    double s = 150;
    var rect = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: s * 2, height: s);

    p1.reset();
    p1.addOval(rect);
    // p1.moveTo(rect.left, rect.top);
    // p1.lineTo(rect.right, rect.top);
    // p1.lineTo(rect.right, rect.bottom);
    // p1.lineTo(rect.left, rect.bottom);
    // p1.close();

    p2.reset();
    p2.moveTo(rect.center.dx, rect.top);
    p2.lineTo(rect.right, rect.bottom);
    p2.lineTo(rect.left, rect.bottom);
    p2.close();

    morph = PathMorph(p1, p2);
  }

  void drawController(Canvas canvas, Size size) {
    p1.reset();
    size = size * 0.3;
    final ss = min(size.width, size.height);

    final rect = Rect.fromCenter(center: Offset.zero, width: ss, height: ss);

    p1.moveTo(rect.left, rect.top);
    p1.arcToPoint(rect.bottomRight, radius: Radius.circular(16));

    mPaint.style = PaintingStyle.stroke;
    mPaint.strokeWidth = 1.5;
    mPaint.color = mat.Colors.black;
    canvas.save();
    canvas.translate(0, -rect.height / 2 - 10);
    canvas.drawPath(p1.rawPath, mPaint);
    canvas.restore();
    final cubics = Cubic.ofOval(rect);

    Path p3 = Path();
    bool moveFirst = true;
    for (var item in cubics) {
      if (moveFirst) {
        p3.moveTo(item.start.dx, item.start.dy);
        moveFirst = false;
      }
      p3.cubicTo(item.c1.dx, item.c1.dy, item.c2.dx, item.c2.dy, item.end.dx, item.end.dy);
    }
    mPaint.color = mat.Colors.red;
    canvas.save();
    canvas.translate(0, rect.height / 2 + 10);
    canvas.drawPath(p1.rawPath, mPaint);
    canvas.restore();
  }

  void drawArc(Canvas canvas) {
    Path p1 = ArcPath(startAngle: 0, sweepAngle: 30, center: Offset(100, 100), innerRadius: 50, outerRadius: 100)
        .createPath();

    canvas.drawPath(p1.rawPath, mPaint);
  }

  @override
  bool shouldRepaint(covariant mat.CustomPainter oldDelegate) => true;

  final Random _random = Random();

  Color randomColor() {
    return Color.fromARGB(255, _random.nextInt(200), _random.nextInt(230), _random.nextInt(80));
  }
}

class ArcPath {
  final double startAngle;   // 起始角度
  final double sweepAngle;   // 扫过角度
  final Offset center;       // 圆心坐标
  final double innerRadius;  // 内半径
  final double outerRadius;  // 外半径
  final double arcPad;       // 弧形之间的间隔（角度）
  final double cornerRadius; // 圆角半径

  ArcPath({
    required this.startAngle,
    required this.sweepAngle,
    required this.center,
    required this.innerRadius,
    required this.outerRadius,
    this.arcPad = 0.0,       // 默认为0，没有间隔
    this.cornerRadius = 0.0, // 默认为0，没有圆角
  });

  Path createPath() {
    final Path path = Path();

    // 调整 startAngle 和 sweepAngle 以添加 arcPad 间隔
    final double adjustedStartAngle = startAngle + arcPad / 2;
    final double adjustedSweepAngle = sweepAngle - arcPad;

    // 将角度转换为弧度
    final double startRadians = adjustedStartAngle * pi / 180;
    final double endRadians = (adjustedStartAngle + adjustedSweepAngle) * pi / 180;

    // 计算外弧的起点和终点
    final Offset outerStartPoint = Offset(
      center.dx + outerRadius * cos(startRadians),
      center.dy + outerRadius * sin(startRadians),
    );
    final Offset outerEndPoint = Offset(
      center.dx + outerRadius * cos(endRadians),
      center.dy + outerRadius * sin(endRadians),
    );

    // 计算内弧的起点和终点
    final Offset innerStartPoint = Offset(
      center.dx + innerRadius * cos(endRadians),
      center.dy + innerRadius * sin(endRadians),
    );
    final Offset innerEndPoint = Offset(
      center.dx + innerRadius * cos(startRadians),
      center.dy + innerRadius * sin(startRadians),
    );

    // 从外弧起点开始
    path.moveTo(outerStartPoint.dx, outerStartPoint.dy);

    // 绘制外圆弧
    path.arcTo(
      Rect.fromCircle(center: center, radius: outerRadius),
      startRadians,
      endRadians - startRadians,
      false,
    );

    // 可选：处理圆角连接
    if (cornerRadius > 0) {
      path.arcToPoint(
        innerStartPoint,
        radius: Radius.circular(cornerRadius),
        clockwise: false,
      );
    } else {
      // 如果没有圆角，直接连接到内弧的起点
      path.lineTo(innerStartPoint.dx, innerStartPoint.dy);
    }

    // 绘制内圆弧
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      endRadians,
      startRadians - endRadians,
      false,
    );

    // 如果有圆角，处理内外弧的连接
    if (cornerRadius > 0) {
      path.arcToPoint(
        outerEndPoint,
        radius: Radius.circular(cornerRadius),
        clockwise: false,
      );
    } else {
      // 如果没有圆角，直接连接到外弧的终点
      path.lineTo(outerEndPoint.dx, outerEndPoint.dy);
    }

    // 闭合路径
    path.close();

    return path;
  }
}

