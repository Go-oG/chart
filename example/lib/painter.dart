import 'dart:math';
import 'dart:ui';

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
    mPaint.style = PaintingStyle.stroke;
    mPaint.color = mat.Colors.black87;
    mPaint.strokeWidth = 2;
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawLine(rect.centerLeft, rect.centerRight, mPaint);
    canvas.drawLine(rect.topCenter, rect.bottomCenter, mPaint);

    mPaint.color = mat.Colors.blueAccent;
    canvas.drawPath(p1.rawPath, mPaint);

    mPaint.color = mat.Colors.deepPurple;
    canvas.drawPath(p2.rawPath, mPaint);

    // mPaint.style = PaintingStyle.fill;
    // for (var item in morph.getControlPoints(true)) {
    //   mPaint.color = randomColor();
    //   for (var cc in item) {
    //     canvas.drawCircle(cc, 6, mPaint);
    //   }
    // }

    mPaint.color = mat.Colors.red;
    for (var item in morph.getControlPoints(false)) {
      for (var offset in item) {
        canvas.drawCircle(offset, 6, mPaint);
      }
    }
    mPaint.style = PaintingStyle.stroke;

  //  canvas.drawPath(morph.lerp(controller.value,true), mPaint);
  }

  void _initIfNeed(Size size) {
    if (_init) {
      return;
    }
    _init = true;
    double s = 150;
    var rect = Rect.fromLTWH(size.width / 2 - s, size.height / 2 - s, s * 2, s * 2);
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
      p3.cubicTo(item.control1.dx, item.control1.dy, item.control2.dx, item.control2.dy, item.end.dx, item.end.dy);
    }
    mPaint.color = mat.Colors.red;
    canvas.save();
    canvas.translate(0, rect.height / 2 + 10);
    canvas.drawPath(p1.rawPath, mPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant mat.CustomPainter oldDelegate) => true;

  final Random _random = Random();

  Color randomColor() {
    return Color.fromARGB(255, _random.nextInt(200), _random.nextInt(230), _random.nextInt(80));
  }
}
