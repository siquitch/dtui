/// An immutable rectangle defined by position and size.
class Rect {
  final int x;
  final int y;
  final int width;
  final int height;

  const Rect(this.x, this.y, this.width, this.height);

  static Rect fromLTRB(int left, int top, int right, int bottom) {
    return Rect(left, top, right - left, bottom - top);
  }

  int get left => x;
  int get top => y;
  int get right => x + width;
  int get bottom => y + height;

  bool contains(int px, int py) {
    return px >= left && px < right && py >= top && py < bottom;
  }

  Rect intersect(Rect other) {
    final l = left > other.left ? left : other.left;
    final t = top > other.top ? top : other.top;
    final r = right < other.right ? right : other.right;
    final b = bottom < other.bottom ? bottom : other.bottom;
    final w = r - l;
    final h = b - t;
    if (w <= 0 || h <= 0) {
      return const Rect(0, 0, 0, 0);
    }
    return Rect(l, t, w, h);
  }

  Rect deflate(int amount) {
    final newWidth = width - amount * 2;
    final newHeight = height - amount * 2;
    if (newWidth <= 0 || newHeight <= 0) {
      return Rect(x + amount, y + amount, 0, 0);
    }
    return Rect(x + amount, y + amount, newWidth, newHeight);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rect &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'Rect($x, $y, $width, $height)';
}
