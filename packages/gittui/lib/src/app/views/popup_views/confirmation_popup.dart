import 'package:dtui/dtui.dart';

class ConfirmationPopup extends Widget {
  final String title;
  final String message;
  final void Function()? onConfirm;
  final void Function()? onCancel;

  ConfirmationPopup({
    required this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
  });

  @override
  void render(Canvas canvas, Rect area) {
    final content = _ConfirmContent(message: message);
    final popup = Popup(
      title: title,
      child: content,
      width: (area.width * 0.5).toInt().clamp(30, 60),
      height: 7,
    );
    popup.render(canvas, area);
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(50, 7);
  }

  @override
  bool handleEvent(InputEvent event) {
    if (event is! KeyEvent) return false;
    switch (event.key) {
      case 'y':
      case keyEnter:
        onConfirm?.call();
        return true;
      case 'n':
      case keyEscape:
        onCancel?.call();
        return true;
      default:
        return false;
    }
  }
}

class _ConfirmContent extends Widget {
  final String message;
  _ConfirmContent({required this.message});

  @override
  void render(Canvas canvas, Rect area) {
    canvas.drawText(area.x, area.y, message, Style.none);
    canvas.drawText(area.x, area.y + 2, '[y]es  [n]o', const Style(dim: true));
  }

  @override
  (int, int) measure(BoxConstraints constraints) =>
      constraints.constrain(message.length, 3);

  @override
  bool handleEvent(InputEvent event) => false;
}
