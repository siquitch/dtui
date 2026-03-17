import 'package:dtui/dtui.dart';

class BranchCreatePopup extends Widget {
  final void Function(String name)? onCreate;
  final void Function()? onCancel;
  final TextInput _textInput;

  BranchCreatePopup({this.onCreate, this.onCancel})
    : _textInput = TextInput(prompt: 'Branch name: ') {
    _textInput.onSubmit = (text) {
      if (text.trim().isNotEmpty) {
        onCreate?.call(text.trim());
      }
    };
  }

  @override
  void render(Canvas canvas, Rect area) {
    final popup = Popup(
      title: 'New Branch',
      child: _textInput,
      width: (area.width * 0.5).toInt().clamp(30, 60),
      height: 5,
      onClose: onCancel,
    );
    popup.render(canvas, area);
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(50, 5);
  }

  @override
  bool handleEvent(InputEvent event) {
    if (event is KeyEvent && event.key == keyEscape) {
      onCancel?.call();
      return true;
    }
    if (event is KeyEvent && event.key == keyEnter) {
      final text = _textInput.text.trim();
      if (text.isNotEmpty) {
        onCreate?.call(text);
      }
      return true;
    }
    return _textInput.handleEvent(event);
  }
}
