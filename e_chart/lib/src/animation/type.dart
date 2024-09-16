enum AnimateType {
  ///淡入淡出
  fade,

  ///沿X和Y方向延伸的动画
  growInX,
  growInY,

  ///morphing 图形之间的形变动画，通过 SVG Path 之间的过渡形成的动画。
  morphing,

  /// 沿Path路径执行的动画
  pathIn,

  ///缩放动画
  scaleX,
  scaleY,

  ///划入动画(不同坐标系下效果不用)
  wave,

  ///缩放动画，沿节点中心缩放
  zoom;
}
