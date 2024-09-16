import 'package:flutter/material.dart';

import '../../model/range.dart';

///给定视图范围和数值范围
/// 通过应用平移和缩放后
/// 计算当前视图对应的数据范围
class ViewPort extends ChangeNotifier {
  RangeD _scaleXRange = RangeD(1.0, 100);

  RangeD _scaleYRange = RangeD(1.0, 1.0);

  RangeD _scrollXRange = RangeD(0, double.infinity);

  RangeD _scrollYRange = RangeD(0, double.infinity);

  ///可视坐标范围
  Rect _area = Rect.zero;

  ///缩放倍数 当为1时 可视区域长度和数据完全映射
  /// >1 时 等价于画布大小增加，可视区域相对变小
  double _scaleX = 1.0;
  double _scaleY = 1.0;

  ///平移
  /// 向左为负 向右为正
  double _translationX = 0.0;

  ///向上为负 向下为正
  double _translationY = 0.0;

  ///存储当前可视区域对应的数值范围
  double _leftValue = 0.0;
  double _topValue = 0.0;
  double _rightValue = 1.0;
  double _bottomValue = 1.0;

  ViewPort();

  ViewPort.fromValue(Rect area) {
    setAreaAndValue(area);
  }

  void setAreaAndValue(Rect area, {bool resetScale = true, bool resetTranslation = true}) {
    _area = area;

    if (resetScale) {
      _scaleX = _scaleY = 1.0;
    }
    if (resetTranslation) {
      _translationX = _translationY = 0.0;
    }

    ///缩放后的每单位像素对应的数值
    var aw = _area.width;
    if (aw == 0) {
      _leftValue = 0;
      _rightValue = 1;
    } else {
      var unit = pixelValue(true);
      _leftValue = -_translationX * unit;
      _rightValue = _leftValue + _area.width * unit;
    }
    var ah = _area.height;
    if (ah == 0) {
      _topValue = 0;
      _bottomValue = 1;
    } else {
      var unit = pixelValue(false);
      _topValue = -_translationY * unit;
      _bottomValue = _topValue + _area.height * unit;
    }
    notifyListeners();
  }

  void setScaleByViewCenter(double scale, [Offset? viewCenter]) {
    if (viewCenter == null) {
      setScale(scale);
      return;
    }
    var cx = viewCenter.dx;
    cx = _leftValue + (_rightValue - _leftValue) * ((cx - _area.left) / _area.width);

    var cy = viewCenter.dy;
    cy = _topValue + (_bottomValue - _topValue) * ((cy - _area.top) / _area.height);

    setScaleX(scale, cx);
    setScaleY(scale, cy);
    notifyListeners();
  }

  /// 设置新的缩放
  /// [center] 缩放中心 其值应为value值 而不是视图坐标
  void setScale(double scale, [Offset? center]) {
    setScaleX(scale, center?.dx);
    setScaleY(scale, center?.dy);
  }

  /// [centerX] 缩放中心 其值应为value值 而不是视图坐标
  void setScaleX(double scaleX, [double? centerX]) {
    scaleX = _scaleXRange.clamp(scaleX);
    if (scaleX == _scaleX) {
      return;
    }
    var oldLeft = _leftValue;
    var oldRange = _rightValue - _leftValue;
    centerX ??= _leftValue + (_rightValue - _leftValue) * 0.5;
    _scaleX = scaleX;
    double s = _area.width / scaleX;
    _leftValue = centerX - s * ((centerX - oldLeft) / oldRange);
    _rightValue = _leftValue + _area.width * pixelValue(true);
    notifyListeners();
  }

  /// [centerY] 缩放中心 其值应为value值 而不是视图坐标
  void setScaleY(double scaleY, [double? centerY]) {
    scaleY = _scaleYRange.clamp(scaleY);
    if (scaleY == _scaleY) {
      return;
    }
    var oldTop = _topValue;
    var oldRange = _bottomValue - oldTop;
    centerY ??= _topValue;

    _scaleY = scaleY;
    double s = _area.height / scaleY;
    _topValue = centerY - s * ((centerY - oldTop) / oldRange);
    _bottomValue = _topValue * _area.height * pixelValue(false);
    notifyListeners();
  }

  double get scaleX => _scaleX;

  double get scaleY => _scaleY;

  void translation(double diffX, double diffY) {
    setTranslationX(diffX + _translationX);
    setTranslationY(diffY + _translationY);
  }

  void setTranslation(double x, double y) {
    setTranslationX(x);
    setTranslationY(y);
  }

  void setTranslationX(double x) {
    x = _scrollXRange.clamp(x);
    if (x == _translationX) {
      return;
    }
    var sub = (_translationX - x) * pixelValue(true);
    _translationX = x;
    _leftValue += sub;
    _rightValue += sub;
    notifyListeners();
  }

  void setTranslationY(double y) {
    y = _scrollYRange.clamp(y);
    if (y == _translationY) {
      return;
    }
    var sub = (_translationY - y) * pixelValue(false);
    _translationY = y;
    _topValue += sub;
    _bottomValue += sub;
    notifyListeners();
  }

  void setTranslationRange(RangeD range) {
    _scrollXRange = range;
    _scrollYRange = range;
  }

  void setTranslationXRange(RangeD range) {
    _scrollXRange = range;
  }

  void setTranslationYRange(RangeD range) {
    _scrollYRange = range;
  }

  void setScaleRange(RangeD range) {
    _scaleXRange = range;
    _scaleYRange = range;
  }

  void setScaleXRange(RangeD range) {
    _scaleXRange = range;
  }

  void setScaleYRange(RangeD range) {
    _scaleYRange = range;
  }

  double get translationX => _translationX;

  double get translationY => _translationY;

  ///返回水平方向上数据归一化范围[0-1]
  Range<double> get hValueRange {
    return Range(_leftValue, _rightValue);
  }

  ///返回竖直方向上数据归一化范围[0-1]
  Range<double> get vValueRange {
    return Range(_topValue, _bottomValue);
  }

  ///返回当前环境下 一个pixel对应的VALUE值
  double pixelValue(bool isX) {
    if (isX) {
      return 1.0 / (_area.width * _scaleX);
    }
    return 1.0 / (_area.height * _scaleY);
  }

  double get virtualWidth => _area.width * _scaleX;

  double get virtualHeight => _area.height * _scaleY;
}
