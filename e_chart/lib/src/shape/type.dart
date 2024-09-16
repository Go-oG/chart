final class ShapeType {
  static const ShapeType arc = ShapeType("arc");
  static const ShapeType circle = ShapeType("circle");
  static const ShapeType polygon = ShapeType("polygon");
  static const ShapeType positive = ShapeType("positive");
  static const ShapeType prism = ShapeType("prism");
  static const ShapeType rect = ShapeType("rect");
  static const ShapeType star = ShapeType("star");
  static const ShapeType empty = ShapeType("empty");

  final String name;

  const ShapeType(this.name);

  @override
  String toString() => name;

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    return other is ShapeType && other.name == name;
  }
}
