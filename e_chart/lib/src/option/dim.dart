///标识维度
///col 对应column 在笛卡尔坐标系中其表示 X,在极坐标系中表示Angle
///row 对应Row 在笛卡尔坐标系中表示Y, 在极坐标中表示Radius
enum Dim {
  x,
  y;

  bool get isX {
    return this == x;
  }

  bool get isY {
    return this == y;
  }

  Dim get invert {
    return isX ? Dim.y : Dim.x;
  }
}
