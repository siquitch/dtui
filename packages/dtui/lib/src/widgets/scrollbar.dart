import '../layout/constraint.dart';
import '../layout/rect.dart';
import '../rendering/canvas.dart';
import '../style/style.dart';
import 'widget.dart';

/// A vertical scrollbar widget.
class Scrollbar extends Widget {
  int totalItems;
  int visibleItems;
  int scrollOffset;
  final Style trackStyle;
  final Style thumbStyle;

  /// Character for the scrollbar track.
  static const String trackChar = '\u2502'; // thin vertical line
  /// Character for the scrollbar thumb.
  static const String thumbChar = '\u2588'; // full block

  Scrollbar({
    required this.totalItems,
    required this.visibleItems,
    required this.scrollOffset,
    this.trackStyle = Style.none,
    this.thumbStyle = Style.none,
  });

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0) return;
    if (totalItems <= 0 || visibleItems <= 0) return;

    final trackHeight = area.height;
    final x = area.left;

    // If all items fit, no scrollbar needed, just draw track
    if (totalItems <= visibleItems) {
      for (var i = 0; i < trackHeight; i++) {
        canvas.drawChar(x, area.top + i, trackChar, trackStyle);
      }
      return;
    }

    // Calculate thumb size and position
    final thumbHeight =
        (trackHeight * visibleItems / totalItems).ceil().clamp(1, trackHeight);
    final maxOffset = totalItems - visibleItems;
    final scrollRatio = maxOffset > 0 ? scrollOffset / maxOffset : 0.0;
    final thumbTop = (scrollRatio * (trackHeight - thumbHeight))
        .round()
        .clamp(0, trackHeight - thumbHeight);

    for (var i = 0; i < trackHeight; i++) {
      final isThumb = i >= thumbTop && i < thumbTop + thumbHeight;
      if (isThumb) {
        canvas.drawChar(x, area.top + i, thumbChar, thumbStyle);
      } else {
        canvas.drawChar(x, area.top + i, trackChar, trackStyle);
      }
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(1, constraints.maxHeight);
  }
}
