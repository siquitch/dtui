import 'package:dtui/dtui.dart';

class ErrorPopup extends Widget {
  final String title;
  final String message;
  final void Function() onClose;

  ErrorPopup({
    required this.title,
    required this.message,
    required this.onClose,
  });

  @override
  void render(Canvas canvas, Rect area) {
    final popWidth = (area.width * 0.75).toInt().clamp(30, area.width - 2);

    final content = _ErrorContent(message: message);
    final popup = Popup(
      title: title,
      titleStyle: const Style(bold: true, foreground: Color.red),
      borderStyle: const Style(foreground: Color.red),
      child: content,
      width: popWidth,
      height: 5,
    );
    popup.render(canvas, area);
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(60, 5);
  }

  @override
  bool handleEvent(InputEvent event) {
    if (event is! KeyEvent) return false;
    switch (event.key) {
      case keyEscape:
      case keyEnter:
      case 'q':
        onClose();
        return true;
      default:
        return false;
    }
  }
}

class _ErrorContent extends Widget {
  final String message;

  _ErrorContent({required this.message});

  @override
  void render(Canvas canvas, Rect area) {
    final display = message.length > area.width
        ? message.substring(0, area.width)
        : message;
    canvas.drawText(area.x, area.y, display, Style.none);
    canvas.drawText(
      area.x,
      area.y + 2,
      'Press Esc to close',
      const Style(dim: true),
    );
  }

  @override
  (int, int) measure(BoxConstraints constraints) =>
      constraints.constrain(constraints.maxWidth, 3);

  @override
  bool handleEvent(InputEvent event) => false;
}
