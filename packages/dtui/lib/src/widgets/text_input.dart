import '../layout/constraint.dart';
import '../layout/rect.dart';
import '../rendering/canvas.dart';
import '../style/style.dart';
import '../terminal/input_parser.dart';
import 'widget.dart';

/// A single-line text input widget.
class TextInput extends Widget {
  String _text;
  int _cursorPosition;
  void Function(String)? onSubmit;
  void Function(String)? onChange;
  final String? prompt;
  final Style textStyle;
  final Style cursorStyle;

  TextInput({
    String text = '',
    this.onSubmit,
    this.onChange,
    this.prompt,
    this.textStyle = Style.none,
    this.cursorStyle = const Style(inverse: true),
  })  : _text = text,
        _cursorPosition = text.length;

  String get text => _text;

  set text(String value) {
    _text = value;
    _cursorPosition = _cursorPosition.clamp(0, _text.length);
  }

  int get cursorPosition => _cursorPosition;

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0) return;

    var x = area.left;
    final y = area.top;

    // Draw prompt
    if (prompt != null) {
      for (var i = 0; i < prompt!.length; i++) {
        if (x >= area.right) break;
        canvas.drawChar(x, y, prompt![i], textStyle);
        x++;
      }
    }

    // Calculate visible text window
    final availableWidth = area.right - x;
    if (availableWidth <= 0) return;

    // Determine scroll to keep cursor visible
    var textStart = 0;
    if (_cursorPosition >= availableWidth) {
      textStart = _cursorPosition - availableWidth + 1;
    }

    // Draw text
    for (var i = 0; i < availableWidth; i++) {
      final charIndex = textStart + i;
      if (charIndex < _text.length) {
        final style = charIndex == _cursorPosition ? cursorStyle : textStyle;
        canvas.drawChar(x + i, y, _text[charIndex], style);
      } else if (charIndex == _cursorPosition) {
        // Cursor at end of text
        canvas.drawChar(x + i, y, ' ', cursorStyle);
      } else {
        break;
      }
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    final promptLen = prompt?.length ?? 0;
    return constraints.constrain(promptLen + _text.length + 1, 1);
  }

  @override
  bool handleEvent(InputEvent event) {
    if (event is! KeyEvent) return false;

    switch (event.key) {
      case keyBackspace:
        if (_cursorPosition > 0) {
          _text = _text.substring(0, _cursorPosition - 1) +
              _text.substring(_cursorPosition);
          _cursorPosition--;
          onChange?.call(_text);
        }
        return true;

      case keyDelete:
        if (_cursorPosition < _text.length) {
          _text = _text.substring(0, _cursorPosition) +
              _text.substring(_cursorPosition + 1);
          onChange?.call(_text);
        }
        return true;

      case keyLeft:
        if (_cursorPosition > 0) {
          _cursorPosition--;
        }
        return true;

      case keyRight:
        if (_cursorPosition < _text.length) {
          _cursorPosition++;
        }
        return true;

      case keyHome:
        _cursorPosition = 0;
        return true;

      case keyEnd:
        _cursorPosition = _text.length;
        return true;

      case keyEnter:
        onSubmit?.call(_text);
        return true;

      default:
        // Handle printable characters and space
        if (!event.ctrl && !event.alt) {
          String? ch;
          if (event.key == keySpace) {
            ch = ' ';
          } else if (event.key.length == 1) {
            ch = event.key;
          }
          if (ch != null) {
            _text = _text.substring(0, _cursorPosition) +
                ch +
                _text.substring(_cursorPosition);
            _cursorPosition++;
            onChange?.call(_text);
            return true;
          }
        }
        return false;
    }
  }
}
