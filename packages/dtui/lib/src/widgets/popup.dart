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
  final Style borderStyle;
  final Style titleStyle;
  final void Function()? onClose;
  bool _visible;

  /// Box drawing characters for the popup border.
  static const _topLeft = '\u256D';
  static const _topRight = '\u256E';
  static const _bottomLeft = '\u2570';
  static const _bottomRight = '\u256F';
  static const _horizontal = '\u2500';
  static const _vertical = '\u2502';

  Popup({
    required this.title,
    required this.child,
    this.width = 60,
    this.height = 20,
    this.borderStyle = Style.none,
    this.titleStyle = const Style(bold: true),
    this.onClose,
    bool visible = true,
  }) : _visible = visible;

  // ignore: unnecessary_getters_setters
  bool get visible => _visible;
  set visible(bool value) => _visible = value;

  @override
  List<Widget> get children => [child];

  @override
  void render(Canvas canvas, Rect area) {
    if (!_visible) return;
    if (area.width <= 0 || area.height <= 0) return;

    // Calculate centered position
    final popWidth = width.clamp(4, area.width);
    final popHeight = height.clamp(3, area.height);
    final px = area.left + ((area.width - popWidth) ~/ 2);
    final py = area.top + ((area.height - popHeight) ~/ 2);
    final popRect = Rect(px, py, popWidth, popHeight);

    // Clear popup area
    final clearCell = Cell(' ', Style.none);
    canvas.fillRect(popRect, clearCell);

    // Draw border
    canvas.drawChar(popRect.left, popRect.top, _topLeft, borderStyle);
    canvas.drawChar(
        popRect.right - 1, popRect.top, _topRight, borderStyle);
    canvas.drawChar(
        popRect.left, popRect.bottom - 1, _bottomLeft, borderStyle);
    canvas.drawChar(
        popRect.right - 1, popRect.bottom - 1, _bottomRight, borderStyle);

    canvas.drawHorizontalLine(popRect.left + 1, popRect.top,
        popRect.width - 2, _horizontal, borderStyle);
    canvas.drawHorizontalLine(popRect.left + 1, popRect.bottom - 1,
        popRect.width - 2, _horizontal, borderStyle);
    canvas.drawVerticalLine(popRect.left, popRect.top + 1,
        popRect.height - 2, _vertical, borderStyle);
    canvas.drawVerticalLine(popRect.right - 1, popRect.top + 1,
        popRect.height - 2, _vertical, borderStyle);

    // Draw title
    if (title.isNotEmpty) {
      final maxTitleLen = popRect.width - 4;
      if (maxTitleLen > 0) {
        final displayTitle =
            title.length > maxTitleLen ? title.substring(0, maxTitleLen) : title;
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
    return constraints.constrain(width, height);
  }

  @override
  bool handleEvent(InputEvent event) {
    if (!_visible) return false;

    if (event is KeyEvent && event.key == keyEscape) {
      _visible = false;
      onClose?.call();
      return true;
    }

    // Delegate to child
    return child.handleEvent(event);
  }
}
