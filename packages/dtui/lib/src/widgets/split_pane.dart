import '../layout/constraint.dart';
import '../layout/layout_engine.dart';
import '../layout/rect.dart';
import '../rendering/canvas.dart';
import '../terminal/input_parser.dart';
import 'widget.dart';

/// A widget that splits its area among multiple children.
class SplitPane extends Widget {
  final SplitDirection direction;
  final List<SplitSpec> specs;
  int focusedIndex;

  final List<Widget> _children;

  SplitPane({
    required this.direction,
    required List<Widget> children,
    required this.specs,
    this.focusedIndex = 0,
  }) : _children = children;

  @override
  List<Widget> get children => _children;

  @override
  void render(Canvas canvas, Rect area) {
    if (_children.isEmpty || area.width <= 0 || area.height <= 0) return;

    final rects = LayoutEngine.split(area, direction, specs);
    for (var i = 0; i < _children.length && i < rects.length; i++) {
      final childCanvas = canvas.subCanvas(rects[i]);
      _children[i].render(childCanvas, rects[i]);
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(
      constraints.hasBoundedWidth ? constraints.maxWidth : 0,
      constraints.hasBoundedHeight ? constraints.maxHeight : 0,
    );
  }

  @override
  bool handleEvent(InputEvent event) {
    if (_children.isEmpty) return false;
    final idx = focusedIndex.clamp(0, _children.length - 1);
    return _children[idx].handleEvent(event);
  }
}
