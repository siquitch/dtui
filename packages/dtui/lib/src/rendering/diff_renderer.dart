import '../style/color.dart';
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
    // If target is plain, just reset
    if (to == Style.none) {
      if (from == null || from == Style.none) return '';
      return Ansi.resetStyle();
    }

    // If coming from null or a complex style, just reset and apply new
    if (from == null || from == Style.none || _needsFullReset(from, to)) {
      final prefix = to.toAnsiPrefix();
      if (prefix.isEmpty) return '';
      if (from != null && from != Style.none) {
        return '${Ansi.resetStyle()}$prefix';
      }
      return prefix;
    }

    // Styles are the same, no transition needed
    if (from == to) return '';

    // Otherwise do a full reset and reapply
    return '${Ansi.resetStyle()}${to.toAnsiPrefix()}';
  }

  /// Check if we need a full reset when transitioning from one style to another.
  bool _needsFullReset(Style from, Style to) {
    // If any attribute was on in 'from' but off in 'to', we need a reset
    // because ANSI doesn't have individual "off" codes for all attributes.
    if (from.bold && !to.bold) return true;
    if (from.dim && !to.dim) return true;
    if (from.italic && !to.italic) return true;
    if (from.underline && !to.underline) return true;
    if (from.strikethrough && !to.strikethrough) return true;
    if (from.inverse && !to.inverse) return true;
    if (from.foreground != null &&
        from.foreground != Color.reset &&
        to.foreground == null) {
      return true;
    }
    if (from.background != null &&
        from.background != Color.reset &&
        to.background == null) {
      return true;
    }
    return false;
  }
}
