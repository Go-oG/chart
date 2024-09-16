enum Position {
  top,
  bottom,
  left,
  right,
  center,
}

enum Align2 { start, center, end }

enum Direction {
  horizontal,
  vertical;

  bool isVertical() {
    return this == Direction.vertical;
  }

  bool isHorizontal() {
    return this == Direction.horizontal;
  }
}

enum Direction2 { ltr, rtl, ttb, btt, h, v }

class Gravity {
  static const center = Gravity(0, 0);

  static const centerTop = Gravity(0, -1);

  static const centerBottom = Gravity(0, 1);

  static const centerLeft = Gravity(-1, 0);

  static const centerRight = Gravity(1, 0);

  static const leftTop = Gravity(-1, -1);

  static const leftBottom = Gravity(-1, 1);

  static const rightBottom = Gravity(1, 1);

  static const rightTop = Gravity(1, -1);

  final int x;
  final int y;

  const Gravity(this.x, this.y);

  @override
  int get hashCode {
    return Object.hash(x, y);
  }

  @override
  bool operator ==(Object other) {
    return other is Gravity && other.x == x && other.y == y;
  }
}
