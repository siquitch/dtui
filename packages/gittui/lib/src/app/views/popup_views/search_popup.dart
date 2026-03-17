import 'package:dtui/dtui.dart';

class SearchPopup extends Widget {
  final void Function(String query)? onSearch;
  final void Function()? onCancel;
  final TextInput _textInput;

  SearchPopup({this.onSearch, this.onCancel})
    : _textInput = TextInput(prompt: '/');

  @override
  void render(Canvas canvas, Rect area) {
    // Render at the bottom of the screen
    if (area.height <= 0 || area.width <= 0) return;
    final y = area.bottom - 1;
    final searchArea = Rect(area.x, y, area.width, 1);

    // Clear line
    for (var x = area.x; x < area.right; x++) {
      canvas.drawChar(x, y, ' ', Style.none);
    }

    _textInput.render(canvas, searchArea);
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(constraints.maxWidth, 1);
  }

  @override
  bool handleEvent(InputEvent event) {
    if (event is KeyEvent && event.key == keyEscape) {
      onCancel?.call();
      return true;
    }
    if (event is KeyEvent && event.key == keyEnter) {
      final query = _textInput.text.trim();
      if (query.isNotEmpty) {
        onSearch?.call(query);
      }
      return true;
    }
    return _textInput.handleEvent(event);
  }
}
