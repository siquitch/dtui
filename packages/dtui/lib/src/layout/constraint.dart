/// Constraints for laying out a box (widget).
class BoxConstraints {
  final int minWidth;
  final int maxWidth;
  final int minHeight;
  final int maxHeight;

  const BoxConstraints({
    this.minWidth = 0,
    this.maxWidth = 0x7FFFFFFF,
    this.minHeight = 0,
    this.maxHeight = 0x7FFFFFFF,
  });

  /// Create tight constraints with exact dimensions.
  const BoxConstraints.tight(int width, int height)
      : minWidth = width,
        maxWidth = width,
        minHeight = height,
        maxHeight = height;

  /// Create loose constraints allowing up to the given dimensions.
  const BoxConstraints.loose(int mw, int mh)
      : minWidth = 0,
        maxWidth = mw,
        minHeight = 0,
        maxHeight = mh;

  /// Whether width and height are both tightly constrained.
  bool get isTight => minWidth == maxWidth && minHeight == maxHeight;

  /// Whether the width has a finite upper bound.
  bool get hasBoundedWidth => maxWidth < 0x7FFFFFFF;

  /// Whether the height has a finite upper bound.
  bool get hasBoundedHeight => maxHeight < 0x7FFFFFFF;

  /// Constrain a desired (width, height) to fit within these constraints.
  (int, int) constrain(int width, int height) {
    final w = width.clamp(minWidth, maxWidth);
    final h = height.clamp(minHeight, maxHeight);
    return (w, h);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoxConstraints &&
        other.minWidth == minWidth &&
        other.maxWidth == maxWidth &&
        other.minHeight == minHeight &&
        other.maxHeight == maxHeight;
  }

  @override
  int get hashCode => Object.hash(minWidth, maxWidth, minHeight, maxHeight);

  @override
  String toString() =>
      'BoxConstraints(minW: $minWidth, maxW: $maxWidth, minH: $minHeight, maxH: $maxHeight)';
}
