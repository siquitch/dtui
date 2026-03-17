import 'package:dtui/dtui.dart';

class CommitMessagePopup extends Widget {
  final void Function(String message)? onCommit;
  final void Function()? onCancel;
  final TextInput _textInput;
  final bool amend;

  CommitMessagePopup({
    this.onCommit,
    this.onCancel,
    this.amend = false,
    String initialText = '',
  }) : _textInput = TextInput(
         text: initialText,
         prompt: '> ',
         onSubmit: null,
       ) {
    _textInput.onSubmit = (text) {
      if (text.trim().isNotEmpty) {
        onCommit?.call(text.trim());
      }
    };
  }

  @override
  void render(Canvas canvas, Rect area) {
    final popup = Popup(
      title: amend ? 'Amend Commit' : 'Commit',
      child: _textInput,
      width: (area.width * 0.6).toInt().clamp(30, 80),
      height: 5,
      onClose: onCancel,
    );
    popup.render(canvas, area);
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(60, 5);
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
        onCommit?.call(text);
      }
      return true;
    }
    return _textInput.handleEvent(event);
  }
}
