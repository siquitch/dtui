import '../layout/constraint.dart';
import '../layout/rect.dart';
import '../rendering/canvas.dart';
import '../terminal/input_parser.dart';

/// Base class for all TUI widgets.
abstract class Widget {
  /// Render this widget into the given [canvas] within [area].
  void render(Canvas canvas, Rect area);

  /// Return the desired (width, height) given the constraints.
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(0, 0);
  }

  /// Handle an input event. Return true if the event was consumed.
  bool handleEvent(InputEvent event) {
    return false;
  }

  /// Child widgets. Override to provide children for composite widgets.
  List<Widget> get children => const [];
}
