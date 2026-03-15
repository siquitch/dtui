import '../layout/rect.dart';
import '../style/style.dart';
import 'buffer.dart';

/// Box-drawing characters for border rendering.
class BoxChars {
  final String topLeft;
  final String topRight;
  final String bottomLeft;
  final String bottomRight;
  final String horizontal;
  final String vertical;

  const BoxChars({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.horizontal,
    required this.vertical,
  });

  /// Single-line box characters.
  const BoxChars.single()
      : topLeft = '\u250C',
        topRight = '\u2510',
        bottomLeft = '\u2514',
        bottomRight = '\u2518',
        horizontal = '\u2500',
        vertical = '\u2502';

  /// Double-line box characters.
  const BoxChars.double_()
      : topLeft = '\u2554',
        topRight = '\u2557',
        bottomLeft = '\u255A',
        bottomRight = '\u255D',
        horizontal = '\u2550',
        vertical = '\u2551';

  /// Rounded box characters.
  const BoxChars.rounded()
      : topLeft = '\u256D',
        topRight = '\u256E',
        bottomLeft = '\u2570',
        bottomRight = '\u256F',
        horizontal = '\u2500',
        vertical = '\u2502';

  /// Heavy box characters.
  const BoxChars.heavy()
      : topLeft = '\u250F',
        topRight = '\u2513',
        bottomLeft = '\u2517',
        bottomRight = '\u251B',
        horizontal = '\u2501',
        vertical = '\u2503';
}

/// A drawing surface backed by a [Buffer] with clipping.
class Canvas {
  final Buffer buffer;
  final Rect clip;

  const Canvas(this.buffer, this.clip);

  /// Draw text at (x, y), clipped to the canvas rect.
  /// Coordinates are relative to the buffer, not the clip.
  void drawText(int x, int y, String text, Style style) {
    if (y < clip.top || y >= clip.bottom) return;
    for (var i = 0; i < text.length; i++) {
      final cx = x + i;
      if (cx < clip.left) continue;
      if (cx >= clip.right) break;
      buffer.setCell(cx, y, Cell(text[i], style));
    }
  }

  /// Draw a single character at (x, y), clipped.
  void drawChar(int x, int y, String char, Style style) {
    if (x < clip.left || x >= clip.right) return;
    if (y < clip.top || y >= clip.bottom) return;
    buffer.setCell(x, y, Cell(char, style));
  }

  /// Fill a rectangle with a cell, clipped to the canvas rect.
  void fillRect(Rect rect, Cell cell) {
    final clipped = rect.intersect(clip);
    buffer.fill(clipped, cell);
  }

  /// Draw a horizontal line starting at (x, y).
  void drawHorizontalLine(
      int x, int y, int length, String char, Style style) {
    if (y < clip.top || y >= clip.bottom) return;
    for (var i = 0; i < length; i++) {
      final cx = x + i;
      if (cx < clip.left) continue;
      if (cx >= clip.right) break;
      buffer.setCell(cx, y, Cell(char, style));
    }
  }

  /// Draw a vertical line starting at (x, y).
  void drawVerticalLine(
      int x, int y, int length, String char, Style style) {
    if (x < clip.left || x >= clip.right) return;
    for (var i = 0; i < length; i++) {
      final cy = y + i;
      if (cy < clip.top) continue;
      if (cy >= clip.bottom) break;
      buffer.setCell(x, cy, Cell(char, style));
    }
  }

  /// Draw a box border within the given rect.
  void drawBox(Rect rect, BoxChars chars, Style style) {
    if (rect.width < 2 || rect.height < 2) return;

    // Corners
    drawChar(rect.left, rect.top, chars.topLeft, style);
    drawChar(rect.right - 1, rect.top, chars.topRight, style);
    drawChar(rect.left, rect.bottom - 1, chars.bottomLeft, style);
    drawChar(rect.right - 1, rect.bottom - 1, chars.bottomRight, style);

    // Top and bottom edges
    drawHorizontalLine(
        rect.left + 1, rect.top, rect.width - 2, chars.horizontal, style);
    drawHorizontalLine(rect.left + 1, rect.bottom - 1, rect.width - 2,
        chars.horizontal, style);

    // Left and right edges
    drawVerticalLine(
        rect.left, rect.top + 1, rect.height - 2, chars.vertical, style);
    drawVerticalLine(rect.right - 1, rect.top + 1, rect.height - 2,
        chars.vertical, style);
  }

  /// Create a sub-canvas with a further-clipped rectangle.
  Canvas subCanvas(Rect rect) {
    final intersection = clip.intersect(rect);
    return Canvas(buffer, intersection);
  }
}
