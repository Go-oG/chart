import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm;

//自定义Tween
class Tween2<T> extends Animatable<T> with Disposable {
  T? _begin;
  T? _end;

  Tween2(T begin, T end) {
    _begin = begin;
    _end = end;
  }

  Tween2.empty();

  T get begin => _begin!;

  T get end => _end!;

  void change(T begin, T end) {
    _begin = begin;
    _end = end;
  }

  /// accept obj.lerp(obj,t) or
  /// obj.lerp(t,obj) or
  /// implements + - *
  @protected
  T lerp(double t) {
    dynamic beginDynamic = begin;
    dynamic endDynamic = end;
    try {
      return beginDynamic.lerp(endDynamic, t) as T;
    } catch (_) {}

    try {
      return beginDynamic.lerp(t, endDynamic) as T;
    } catch (_) {}

    return (begin as dynamic) + ((end as dynamic) - (begin as dynamic)) * t as T;
  }

  @override
  T transform(double t) {
    if (t == 0.0) {
      return begin;
    }
    if (t == 1.0) {
      return end;
    }
    return lerp(t);
  }

  @override
  String toString() => '$runtimeType($begin \u2192 $end)';

  @override
  void dispose() {
    super.dispose();
    _begin = null;
    _end = null;
  }
}

class TweenSet extends Tween2<List<dynamic>> {
  List<Tween> _tweenList = [];
  TweenSet(this._tweenList) : super([], []);

  @override
  List<dynamic> lerp(double t) {
    List<dynamic> list = [];
    for (var item in _tweenList) {
      list.add(item.lerp(t));
    }
    return list;
  }

  @override
  List<dynamic> transform(double t) {
    return lerp(t);
  }
}

class ReverseTween<T extends Object> extends Tween2<T> {
  ReverseTween(this.parent) : super(parent.end, parent.begin);

  final Tween2<T> parent;

  @override
  T lerp(double t) => parent.lerp(1.0 - t);
}

class ColorTween extends Tween2<Color> {
  ColorTween(super.begin, super.end);

  @override
  Color lerp(double t) => Color.lerp(begin, end, t)!;
}

class SizeTween extends Tween2<Size> {
  SizeTween(super.begin, super.end);

  @override
  Size lerp(double t) => Size.lerp(begin, end, t)!;
}

class RectTween extends Tween2<Rect> {
  RectTween(super.begin, super.end);

  @override
  Rect lerp(double t) => Rect.lerp(begin, end, t)!;
}

class IntTween extends Tween2<int> {
  IntTween(super.begin, super.end);

  @override
  int lerp(double t) => (begin + (end - begin) * t).round();
}

class StepTween extends Tween2<int> {
  StepTween(super.begin, super.end);

  @override
  int lerp(double t) => (begin + (end - begin) * t).floor();
}

class ConstantTween<T extends Object> extends Tween2<T> {
  ConstantTween(T value) : super(value, value);

  @override
  T lerp(double t) => begin;

  @override
  String toString() => '${objectRuntimeType(this, 'ConstantTween')}(value: $begin)';
}

class CurveTween extends Tween2<double> {
  CurveTween(this.curve) : super(0, 1);

  Curve curve;

  @override
  double transform(double t) {
    if (t == 0.0 || t == 1.0) {
      assert(curve.transform(t).round() == t);
      return t;
    }
    return curve.transform(t);
  }

  @override
  String toString() => '${objectRuntimeType(this, 'CurveTween')}(curve: $curve)';
}

class RRectTween extends Tween2<RRect> {
  RRectTween(super.begin, super.end);

  @override
  RRect lerp(double t) {
    return RRect.lerp(begin, end, t)!;
  }
}

class BoxShadowTween extends Tween2<BoxShadow> {
  BoxShadowTween(super.begin, super.end);

  @override
  BoxShadow lerp(double t) {
    return BoxShadow.lerp(begin, end, t)!;
  }
}

class OffsetTween extends Tween2<Offset> {
  OffsetTween(super.begin, super.end);

  @override
  Offset lerp(double t) {
    return Offset.lerp(begin, end, t)!;
  }
}

class Matrix4Tween extends Tween2<vm.Matrix4> {
  Matrix4Tween(super.begin, super.end);

  @override
  vm.Matrix4 lerp(double t) {
    final vm.Vector3 beginTranslation = vm.Vector3.zero();
    final vm.Vector3 endTranslation = vm.Vector3.zero();
    final vm.Quaternion beginRotation = vm.Quaternion.identity();
    final vm.Quaternion endRotation = vm.Quaternion.identity();
    final vm.Vector3 beginScale = vm.Vector3.zero();
    final vm.Vector3 endScale = vm.Vector3.zero();
    begin.decompose(beginTranslation, beginRotation, beginScale);
    end.decompose(endTranslation, endRotation, endScale);
    final vm.Vector3 lerpTranslation = beginTranslation * (1.0 - t) + endTranslation * t;
    final vm.Quaternion lerpRotation = (beginRotation.scaled(1.0 - t) + endRotation.scaled(t)).normalized();
    final vm.Vector3 lerpScale = beginScale * (1.0 - t) + endScale * t;
    return vm.Matrix4.compose(lerpTranslation, lerpRotation, lerpScale);
  }
}

class ShaderTween extends Tween2<CShader> {
  ShaderTween(super.begin, super.end);

  @override
  CShader lerp(double t) {
    return begin.lerp(end, t);
  }
}

class LineStyleTween extends Tween2<LineStyle> {
  ShaderTween? _shaderTween;

  LineStyleTween(super.begin, super.end);

  @override
  LineStyle lerp(double t) {
    var begin = this.begin;
    var end = this.end;
    List<num> dash;
    if (begin.dash.length == end.dash.length && begin.dash.isNotEmpty) {
      dash = [];
      for (int i = 0; i < begin.dash.length; i++) {
        dash.add(lerpDouble(begin.dash[i], end.dash[i], t)!);
      }
    } else {
      dash = t < 0.5 ? begin.dash : end.dash;
    }

    List<BoxShadow> shadowList = BoxShadow.lerpList(begin.shadow, end.shadow, t) ?? [];
    CShader? shader;
    if (_shaderTween != null) {
      shader = _shaderTween!.transform(t);
    } else {
      shader = t < 0.5 ? begin.shader : end.shader;
    }
    return LineStyle(
      color: Color.lerp(begin.color, end.color, t)!,
      width: lerpDouble(begin.width, end.width, t)!,
      cap: begin.cap == StrokeCap.butt ? end.cap : begin.cap,
      join: begin.join == StrokeJoin.miter ? end.join : begin.join,
      dash: dash,
      shadow: shadowList,
      shader: shader,
      smooth: t < 0.5 ? begin.smooth : end.smooth,
    );
  }
}

class AreaStyleTween extends Tween2<AreaStyle> {
  AreaStyleTween(super.begin, super.end);

  @override
  AreaStyle lerp(double t) {
    return AreaStyle.lerp(begin, end, t)!;
  }
}

class TextStyleTween extends Tween2<TextStyle> {
  TextStyleTween(super.begin, super.end);

  @override
  TextStyle lerp(double t) {
    return TextStyle.lerp(begin, end, t)!;
  }
}

class ArcTween extends Tween2<Arc> {
  ArcTween(super.begin, super.end);

  @override
  Arc lerp(double t) {
    return lerpArc(begin, end, t);
  }
}
