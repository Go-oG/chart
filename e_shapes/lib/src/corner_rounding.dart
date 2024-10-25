class CornerRounding {
  static const CornerRounding unRounded = CornerRounding(0, 0);
  final double radius;
  final double smoothing;

  const CornerRounding(this.radius, [this.smoothing = 0]);

  @override
  int get hashCode=> Object.hash(radius, smoothing);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }

    return other is CornerRounding && other.radius == radius && other.smoothing == smoothing;
  }
}
