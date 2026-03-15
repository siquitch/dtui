import '../layout/constraint.dart';
import '../layout/rect.dart';
import '../rendering/canvas.dart';
import '../style/style.dart';
import '../terminal/input_parser.dart';
import 'widget.dart';

/// A widget that draws a border around a child widget.
class Border extends Widget {
  final Widget child;
  final String? title;
  final BoxChars chars;
  final Style borderStyle;
  final Style titleStyle;
  final bool focused;

  /// Style to use when focused (defaults to bold border).
  final Style? focusedBorderStyle;

  Border({
    required this.child,
    this.title,
    this.chars = const BoxChars.rounded(),
    this.borderStyle = Style.none,
    this.titleStyle = Style.none,
    this.focused = false,
    this.focusedBorderStyle,
  });

  @override
  List<Widget> get children => [child];

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width < 2 || area.height < 2) return;

    final style = focused
        ? (focusedBorderStyle ?? borderStyle.copyWith(bold: true))
        : borderStyle;

    canvas.drawBox(area, chars, style);

    // Draw title in top border
    if (title != null && title!.isNotEmpty) {
      final maxTitleLen = area.width - 4; // leave room for corners and padding
      if (maxTitleLen > 0) {
        final displayTitle = title!.length > maxTitleLen
            ? title!.substring(0, maxTitleLen)
            : title!;
        final titleX = area.left + 2;
        final titleY = area.top;
        canvas.drawText(titleX, titleY, displayTitle, titleStyle);
      }
    }

    // Render child inside the border
    final innerArea = area.deflate(1);
    if (innerArea.width > 0 && innerArea.height > 0) {
      final innerCanvas = canvas.subCanvas(innerArea);
      child.render(innerCanvas, innerArea);
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    // Child measures within reduced constraints, then add 2 for border
    final innerConstraints = BoxConstraints(
      minWidth: (constraints.minWidth - 2).clamp(0, constraints.maxWidth),
      maxWidth: (constraints.maxWidth - 2).clamp(0, constraints.maxWidth),
      minHeight: (constraints.minHeight - 2).clamp(0, constraints.maxHeight),
      maxHeight: (constraints.maxHeight - 2).clamp(0, constraints.maxHeight),
    );
    final (childW, childH) = child.measure(innerConstraints);
    return constraints.constrain(childW + 2, childH + 2);
  }

  @override
  bool handleEvent(InputEvent event) {
    return child.handleEvent(event);
  }
}
