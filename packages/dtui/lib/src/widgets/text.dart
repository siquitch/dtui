import '../layout/constraint.dart';
import '../layout/rect.dart';
import '../rendering/canvas.dart';
import '../style/style.dart';
import 'widget.dart';

/// A span of styled text.
class TextSpan {
  final String text;
  final Style style;

  const TextSpan(this.text, {this.style = Style.none});
}

/// A simple text widget that renders a single string.
class Text extends Widget {
  final String text;
  final Style style;

  Text(this.text, {this.style = Style.none});

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0) return;

    // Render text, wrapping at area boundaries
    var x = area.left;
    var y = area.top;

    for (var i = 0; i < text.length; i++) {
      if (text[i] == '\n') {
        y++;
        x = area.left;
        if (y >= area.bottom) break;
        continue;
      }

      if (x >= area.right) {
        // Move to next line on overflow
        y++;
        x = area.left;
        if (y >= area.bottom) break;
      }

      canvas.drawChar(x, y, text[i], style);
      x++;
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    // Simple measurement: text length for width, 1 for height
    final lines = text.split('\n');
    var maxWidth = 0;
    for (final line in lines) {
      if (line.length > maxWidth) maxWidth = line.length;
    }
    return constraints.constrain(maxWidth, lines.length);
  }
}

/// A widget that renders multiple styled text spans sequentially.
class RichText extends Widget {
  final List<TextSpan> spans;

  RichText(this.spans);

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0) return;

    var x = area.left;
    var y = area.top;

    for (final span in spans) {
      for (var i = 0; i < span.text.length; i++) {
        if (span.text[i] == '\n') {
          y++;
          x = area.left;
          if (y >= area.bottom) return;
          continue;
        }

        if (x >= area.right) {
          y++;
          x = area.left;
          if (y >= area.bottom) return;
        }

        canvas.drawChar(x, y, span.text[i], span.style);
        x++;
      }
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    var totalLength = 0;
    var lineCount = 1;
    for (final span in spans) {
      totalLength += span.text.length;
      lineCount += span.text.split('\n').length - 1;
    }
    return constraints.constrain(totalLength, lineCount);
  }
}
