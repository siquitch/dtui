import '../layout/constraint.dart';
import '../layout/rect.dart';
import '../rendering/buffer.dart';
import '../rendering/canvas.dart';
import '../style/style.dart';
import '../terminal/input_parser.dart';
import 'widget.dart';

/// A popup widget that centers content over the screen.
class Popup extends Widget {
  final String title;
  final Widget child;
  final int width;
  final int height;
  final BoxChars chars;
  final Style borderStyle;
  final Style titleStyle;
  final void Function()? onClose;
  bool visible;

  Popup({
    required this.title,
    required this.child,
    this.width = 60,
    this.height = 20,
    this.chars = const BoxChars.rounded(),
    this.borderStyle = Style.none,
    this.titleStyle = const Style(bold: true),
    this.onClose,
    this.visible = true,
  });

  @override
  List<Widget> get children => [child];

  @override
  void render(Canvas canvas, Rect area) {
    if (!visible) return;
    if (area.width <= 0 || area.height <= 0) return;

    // Calculate centered position
    final popWidth = width.clamp(4, area.width);
    final popHeight = height.clamp(3, area.height);
    final px = area.left + ((area.width - popWidth) ~/ 2);
    final py = area.top + ((area.height - popHeight) ~/ 2);
    final popRect = Rect(px, py, popWidth, popHeight);

    // Clear popup area
    canvas.fillRect(popRect, Cell(' ', Style.none));

    // Draw border
    canvas.drawBox(popRect, chars, borderStyle);

    // Draw title
    if (title.isNotEmpty) {
      final maxTitleLen = popRect.width - 4;
      if (maxTitleLen > 0) {
        final displayTitle = title.length > maxTitleLen
            ? title.substring(0, maxTitleLen)
            : title;
        canvas.drawText(
            popRect.left + 2, popRect.top, displayTitle, titleStyle);
      }
    }

    // Render child inside popup
    final innerRect = popRect.deflate(1);
    if (innerRect.width > 0 && innerRect.height > 0) {
      final innerCanvas = canvas.subCanvas(innerRect);
      child.render(innerCanvas, innerRect);
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    final (childW, childH) = child.measure(BoxConstraints(
      minWidth: (constraints.minWidth - 2).clamp(0, constraints.maxWidth),
      maxWidth: (constraints.maxWidth - 2).clamp(0, constraints.maxWidth),
      minHeight: (constraints.minHeight - 2).clamp(0, constraints.maxHeight),
      maxHeight: (constraints.maxHeight - 2).clamp(0, constraints.maxHeight),
    ));
    return constraints.constrain(
      (childW + 2).clamp(width, constraints.maxWidth),
      (childH + 2).clamp(height, constraints.maxHeight),
    );
  }

  @override
  bool handleEvent(InputEvent event) {
    if (!visible) return false;

    if (event is KeyEvent && event.key == keyEscape) {
      visible = false;
      onClose?.call();
      return true;
    }

    // Delegate to child
    return child.handleEvent(event);
  }
}
