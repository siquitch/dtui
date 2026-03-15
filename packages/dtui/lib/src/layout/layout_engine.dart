import 'rect.dart';

/// Direction for splitting an area.
enum SplitDirection { horizontal, vertical }

/// Specification for a split: either a flex ratio or a fixed size.
class SplitSpec {
  final double flex;
  final int? fixedSize;

  /// Create a flex-based split specification.
  const SplitSpec.flex(this.flex) : fixedSize = null;

  /// Create a fixed-size split specification.
  const SplitSpec.fixed(int size)
      : fixedSize = size,
        flex = 0;
}

/// Layout engine for splitting areas into sub-rectangles.
class LayoutEngine {
  LayoutEngine._();

  /// Divide [area] into rectangles based on [specs] along [direction].
  ///
  /// Fixed-size specs consume their exact amount first.
  /// Remaining space is divided among flex specs proportionally.
  static List<Rect> split(
      Rect area, SplitDirection direction, List<SplitSpec> specs) {
    if (specs.isEmpty) return [];

    final totalSize =
        direction == SplitDirection.horizontal ? area.width : area.height;

    // Calculate fixed space usage
    var fixedTotal = 0;
    var flexTotal = 0.0;
    for (final spec in specs) {
      if (spec.fixedSize != null) {
        fixedTotal += spec.fixedSize!;
      } else {
        flexTotal += spec.flex;
      }
    }

    final flexSpace = (totalSize - fixedTotal).clamp(0, totalSize);

    final result = <Rect>[];
    var offset = direction == SplitDirection.horizontal ? area.x : area.y;

    for (final spec in specs) {
      int size;
      if (spec.fixedSize != null) {
        size = spec.fixedSize!;
      } else {
        size = flexTotal > 0 ? (flexSpace * spec.flex / flexTotal).round() : 0;
      }

      if (direction == SplitDirection.horizontal) {
        result.add(Rect(offset, area.y, size, area.height));
      } else {
        result.add(Rect(area.x, offset, area.width, size));
      }

      offset += size;
    }

    // Adjust the last rect to absorb rounding errors
    if (result.isNotEmpty) {
      final last = result.last;
      if (direction == SplitDirection.horizontal) {
        final remaining = (area.x + area.width) - last.x;
        if (remaining > 0 && remaining != last.width) {
          result[result.length - 1] =
              Rect(last.x, last.y, remaining, last.height);
        }
      } else {
        final remaining = (area.y + area.height) - last.y;
        if (remaining > 0 && remaining != last.height) {
          result[result.length - 1] =
              Rect(last.x, last.y, last.width, remaining);
        }
      }
    }

    return result;
  }
}
