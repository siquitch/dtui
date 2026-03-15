import '../layout/rect.dart';
import '../style/style.dart';

/// A single cell in the terminal buffer.
class Cell {
  final String char;
  final Style style;

  const Cell(this.char, this.style);

  static const Cell empty = Cell(' ', Style.none);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cell && other.char == char && other.style == style;
  }

  @override
  int get hashCode => Object.hash(char, style);
}

/// A 2D grid of [Cell]s representing the terminal screen.
class Buffer {
  final int width;
  final int height;
  final List<Cell> _cells;

  /// Create a buffer filled with empty (space) cells.
  Buffer(this.width, this.height)
      : _cells = List<Cell>.filled(width * height, Cell.empty);

  Buffer._(this.width, this.height, this._cells);

  /// Get the cell at (x, y).
  Cell getCell(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return Cell.empty;
    }
    return _cells[y * width + x];
  }

  /// Set the cell at (x, y).
  void setCell(int x, int y, Cell cell) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    _cells[y * width + x] = cell;
  }

  /// Write a string starting at (x, y) with the given style.
  void writeString(int x, int y, String text, Style style) {
    if (y < 0 || y >= height) return;
    for (var i = 0; i < text.length; i++) {
      final cx = x + i;
      if (cx < 0) continue;
      if (cx >= width) break;
      _cells[y * width + cx] = Cell(text[i], style);
    }
  }

  /// Fill a rectangular area with a cell.
  void fill(Rect rect, Cell cell) {
    for (var row = rect.top; row < rect.bottom; row++) {
      if (row < 0 || row >= height) continue;
      for (var col = rect.left; col < rect.right; col++) {
        if (col < 0 || col >= width) continue;
        _cells[row * width + col] = cell;
      }
    }
  }

  /// Reset all cells to empty spaces.
  void clear() {
    for (var i = 0; i < _cells.length; i++) {
      _cells[i] = Cell.empty;
    }
  }

  /// Create a deep copy of this buffer.
  Buffer clone() {
    return Buffer._(width, height, List<Cell>.from(_cells));
  }
}
