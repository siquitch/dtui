import '../style/style.dart';
import '../terminal/ansi.dart';
import 'buffer.dart';

/// Renders buffer differences as minimal ANSI escape sequences.
class DiffRenderer {
  /// Compare two buffers cell-by-cell and produce minimal ANSI output
  /// for only the changed cells.
  String render(Buffer previous, Buffer current) {
    final buf = StringBuffer();
    final width = current.width;
    final height = current.height;

    Style? activeStyle;
    int lastX = -2;
    int lastY = -1;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final prevCell = (x < previous.width && y < previous.height)
            ? previous.getCell(x, y)
            : null;
        final currCell = current.getCell(x, y);

        if (prevCell != null && prevCell == currCell) continue;

        // Need to render this cell. Move cursor if not sequential.
        if (y != lastY || x != lastX + 1) {
          buf.write(Ansi.moveTo(x, y));
        }

        // Apply style if different from current active style
        if (activeStyle != currCell.style) {
          buf.write(_buildStyleTransition(activeStyle, currCell.style));
          activeStyle = currCell.style;
        }

        buf.write(currCell.char);
        lastX = x;
        lastY = y;
      }
    }

    // Reset style at end
    if (activeStyle != null && activeStyle != Style.none) {
      buf.write(Ansi.resetStyle());
    }

    return buf.toString();
  }

  /// Render the full buffer (for the first frame).
  String renderFull(Buffer buffer) {
    final buf = StringBuffer();
    buf.write(Ansi.moveTo(0, 0));

    Style? activeStyle;

    for (var y = 0; y < buffer.height; y++) {
      if (y > 0) {
        buf.write(Ansi.moveTo(0, y));
      }
      for (var x = 0; x < buffer.width; x++) {
        final cell = buffer.getCell(x, y);

        if (activeStyle != cell.style) {
          buf.write(_buildStyleTransition(activeStyle, cell.style));
          activeStyle = cell.style;
        }

        buf.write(cell.char);
      }
    }

    if (activeStyle != null && activeStyle != Style.none) {
      buf.write(Ansi.resetStyle());
    }

    return buf.toString();
  }

  /// Build a minimal ANSI transition from one style to another.
  String _buildStyleTransition(Style? from, Style to) {
    // No transition needed if styles match
    if (from == to) return '';

    // Target is plain — just reset (if we had styling active)
    if (to == Style.none) {
      if (from == null || from == Style.none) return '';
      return Ansi.resetStyle();
    }

    // Coming from nothing — just apply new style
    if (from == null || from == Style.none) {
      return to.toAnsiPrefix();
    }

    // Reset and reapply (ANSI lacks individual attribute "off" codes)
    return '${Ansi.resetStyle()}${to.toAnsiPrefix()}';
  }
}
