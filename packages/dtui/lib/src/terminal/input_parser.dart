import 'dart:async';

// Named key constants
const String keyUp = 'Up';
const String keyDown = 'Down';
const String keyLeft = 'Left';
const String keyRight = 'Right';
const String keyEnter = 'Enter';
const String keyEscape = 'Escape';
const String keyBackspace = 'Backspace';
const String keyDelete = 'Delete';
const String keyTab = 'Tab';
const String keyHome = 'Home';
const String keyEnd = 'End';
const String keyPageUp = 'PageUp';
const String keyPageDown = 'PageDown';
const String keyF1 = 'F1';
const String keyF2 = 'F2';
const String keyF3 = 'F3';
const String keyF4 = 'F4';
const String keyF5 = 'F5';
const String keyF6 = 'F6';
const String keyF7 = 'F7';
const String keyF8 = 'F8';
const String keyF9 = 'F9';
const String keyF10 = 'F10';
const String keyF11 = 'F11';
const String keyF12 = 'F12';
const String keySpace = 'Space';

/// Mouse button types.
enum MouseButton { left, right, middle, scrollUp, scrollDown, none }

/// Mouse action types.
enum MouseAction { press, release, drag }

/// Base class for all terminal input events.
sealed class InputEvent {
  const InputEvent();
}

/// A keyboard event.
class KeyEvent extends InputEvent {
  final String key;
  final bool ctrl;
  final bool alt;
  final bool shift;

  const KeyEvent(this.key, {this.ctrl = false, this.alt = false, this.shift = false});

  @override
  String toString() =>
      'KeyEvent($key${ctrl ? ', ctrl' : ''}${alt ? ', alt' : ''}${shift ? ', shift' : ''})';
}

/// A terminal resize event.
class ResizeEvent extends InputEvent {
  final int width;
  final int height;

  const ResizeEvent(this.width, this.height);

  @override
  String toString() => 'ResizeEvent($width, $height)';
}

/// A mouse event.
class MouseEvent extends InputEvent {
  final int x;
  final int y;
  final MouseButton button;
  final MouseAction action;

  const MouseEvent(this.x, this.y, this.button, this.action);

  @override
  String toString() => 'MouseEvent($x, $y, $button, $action)';
}

/// Parses raw terminal byte input into [InputEvent]s.
class InputParser {
  /// Convert a raw byte stream from stdin into a stream of [InputEvent]s.
  Stream<InputEvent> parse(Stream<List<int>> rawInput) {
    final controller = StreamController<InputEvent>();
    rawInput.listen(
      (bytes) {
        _parseBytes(bytes, controller);
      },
      onError: controller.addError,
      onDone: controller.close,
    );
    return controller.stream;
  }

  void _parseBytes(List<int> bytes, StreamController<InputEvent> controller) {
    var i = 0;
    while (i < bytes.length) {
      // Escape sequence
      if (bytes[i] == 0x1B) {
        if (i + 1 < bytes.length && bytes[i + 1] == 0x5B) {
          // CSI sequence: ESC [
          i += 2;
          i = _parseCsi(bytes, i, controller);
        } else if (i + 1 < bytes.length && bytes[i + 1] == 0x4F) {
          // SS3 sequence: ESC O (F1-F4)
          i += 2;
          if (i < bytes.length) {
            final c = bytes[i];
            i++;
            switch (c) {
              case 0x50:
                controller.add(const KeyEvent(keyF1));
              case 0x51:
                controller.add(const KeyEvent(keyF2));
              case 0x52:
                controller.add(const KeyEvent(keyF3));
              case 0x53:
                controller.add(const KeyEvent(keyF4));
              default:
                controller.add(KeyEvent(String.fromCharCode(c), alt: true));
            }
          }
        } else if (i + 1 < bytes.length) {
          // Alt+key: ESC followed by a character
          i++;
          final c = bytes[i];
          i++;
          if (c >= 0x61 && c <= 0x7A) {
            // Alt + lowercase letter
            controller.add(KeyEvent(String.fromCharCode(c), alt: true));
          } else if (c >= 0x41 && c <= 0x5A) {
            // Alt + uppercase letter
            controller.add(
                KeyEvent(String.fromCharCode(c + 32), alt: true, shift: true));
          } else {
            controller.add(KeyEvent(String.fromCharCode(c), alt: true));
          }
        } else {
          // Lone escape
          controller.add(const KeyEvent(keyEscape));
          i++;
        }
      } else if (bytes[i] == 0x0D || bytes[i] == 0x0A) {
        // Enter
        controller.add(const KeyEvent(keyEnter));
        i++;
      } else if (bytes[i] == 0x09) {
        // Tab
        controller.add(const KeyEvent(keyTab));
        i++;
      } else if (bytes[i] == 0x7F) {
        // Backspace (most terminals)
        controller.add(const KeyEvent(keyBackspace));
        i++;
      } else if (bytes[i] == 0x08) {
        // Backspace (alternative)
        controller.add(const KeyEvent(keyBackspace));
        i++;
      } else if (bytes[i] >= 0x01 && bytes[i] <= 0x1A) {
        // Ctrl+letter (Ctrl+A=0x01 .. Ctrl+Z=0x1A)
        final letter = String.fromCharCode(bytes[i] + 0x60);
        controller.add(KeyEvent(letter, ctrl: true));
        i++;
      } else if (bytes[i] == 0x20) {
        // Space
        controller.add(const KeyEvent(keySpace));
        i++;
      } else if (bytes[i] >= 0x21 && bytes[i] <= 0x7E) {
        // Printable ASCII
        controller.add(KeyEvent(String.fromCharCode(bytes[i])));
        i++;
      } else if (bytes[i] >= 0x80) {
        // UTF-8 multi-byte sequence
        final start = i;
        final firstByte = bytes[i];
        int charLen;
        if (firstByte & 0xE0 == 0xC0) {
          charLen = 2;
        } else if (firstByte & 0xF0 == 0xE0) {
          charLen = 3;
        } else if (firstByte & 0xF8 == 0xF0) {
          charLen = 4;
        } else {
          // Invalid UTF-8, skip
          i++;
          continue;
        }
        if (start + charLen <= bytes.length) {
          final codeUnits = bytes.sublist(start, start + charLen);
          final char = String.fromCharCodes(_decodeUtf8(codeUnits));
          controller.add(KeyEvent(char));
          i += charLen;
        } else {
          i++;
        }
      } else {
        i++;
      }
    }
  }

  /// Parse a CSI sequence starting after ESC [.
  int _parseCsi(
      List<int> bytes, int i, StreamController<InputEvent> controller) {
    // Check for SGR mouse: ESC [ < ...
    if (i < bytes.length && bytes[i] == 0x3C) {
      // SGR mouse: ESC [ < Cb ; Cx ; Cy M/m
      i++; // skip '<'
      return _parseSgrMouse(bytes, i, controller);
    }

    // Collect parameter bytes (digits and semicolons)
    final params = StringBuffer();
    while (i < bytes.length &&
        ((bytes[i] >= 0x30 && bytes[i] <= 0x3B))) {
      params.write(String.fromCharCode(bytes[i]));
      i++;
    }

    if (i >= bytes.length) return i;

    final finalByte = bytes[i];
    i++;

    final paramStr = params.toString();

    // Handle tilde sequences: ESC [ N ~
    if (finalByte == 0x7E) {
      switch (paramStr) {
        case '1':
          controller.add(const KeyEvent(keyHome));
        case '2':
          controller.add(const KeyEvent('Insert'));
        case '3':
          controller.add(const KeyEvent(keyDelete));
        case '4':
          controller.add(const KeyEvent(keyEnd));
        case '5':
          controller.add(const KeyEvent(keyPageUp));
        case '6':
          controller.add(const KeyEvent(keyPageDown));
        case '15':
          controller.add(const KeyEvent(keyF5));
        case '17':
          controller.add(const KeyEvent(keyF6));
        case '18':
          controller.add(const KeyEvent(keyF7));
        case '19':
          controller.add(const KeyEvent(keyF8));
        case '20':
          controller.add(const KeyEvent(keyF9));
        case '21':
          controller.add(const KeyEvent(keyF10));
        case '23':
          controller.add(const KeyEvent(keyF11));
        case '24':
          controller.add(const KeyEvent(keyF12));
        default:
          // Modified key: param;modifier~
          _handleModifiedTilde(paramStr, controller);
      }
      return i;
    }

    // Parse modifier from params like "1;2" or "1;5"
    bool shift = false;
    bool alt = false;
    bool ctrl = false;
    if (paramStr.contains(';')) {
      final parts = paramStr.split(';');
      if (parts.length >= 2) {
        final mod = int.tryParse(parts.last) ?? 1;
        _applyModifier(mod, (s, a, c) {
          shift = s;
          alt = a;
          ctrl = c;
        });
      }
    }

    switch (finalByte) {
      case 0x41: // A - Up
        controller.add(KeyEvent(keyUp, shift: shift, alt: alt, ctrl: ctrl));
      case 0x42: // B - Down
        controller.add(KeyEvent(keyDown, shift: shift, alt: alt, ctrl: ctrl));
      case 0x43: // C - Right
        controller.add(KeyEvent(keyRight, shift: shift, alt: alt, ctrl: ctrl));
      case 0x44: // D - Left
        controller.add(KeyEvent(keyLeft, shift: shift, alt: alt, ctrl: ctrl));
      case 0x48: // H - Home
        controller.add(KeyEvent(keyHome, shift: shift, alt: alt, ctrl: ctrl));
      case 0x46: // F - End
        controller.add(KeyEvent(keyEnd, shift: shift, alt: alt, ctrl: ctrl));
      case 0x5A: // Z - Shift+Tab
        controller.add(const KeyEvent(keyTab, shift: true));
      default:
        // Unknown CSI sequence, ignore
        break;
    }

    return i;
  }

  void _handleModifiedTilde(
      String paramStr, StreamController<InputEvent> controller) {
    final parts = paramStr.split(';');
    if (parts.length < 2) return;

    final keyCode = parts[0];
    final mod = int.tryParse(parts[1]) ?? 1;
    bool shift = false;
    bool alt = false;
    bool ctrl = false;
    _applyModifier(mod, (s, a, c) {
      shift = s;
      alt = a;
      ctrl = c;
    });

    String? key;
    switch (keyCode) {
      case '1':
        key = keyHome;
      case '3':
        key = keyDelete;
      case '4':
        key = keyEnd;
      case '5':
        key = keyPageUp;
      case '6':
        key = keyPageDown;
      case '15':
        key = keyF5;
      case '17':
        key = keyF6;
      case '18':
        key = keyF7;
      case '19':
        key = keyF8;
      case '20':
        key = keyF9;
      case '21':
        key = keyF10;
      case '23':
        key = keyF11;
      case '24':
        key = keyF12;
    }

    if (key != null) {
      controller.add(KeyEvent(key, shift: shift, alt: alt, ctrl: ctrl));
    }
  }

  void _applyModifier(
      int mod, void Function(bool shift, bool alt, bool ctrl) apply) {
    // Modifier encoding: value = 1 + (shift ? 1 : 0) + (alt ? 2 : 0) + (ctrl ? 4 : 0)
    final m = mod - 1;
    apply(m & 1 != 0, m & 2 != 0, m & 4 != 0);
  }

  /// Parse SGR mouse sequence after ESC [ <
  int _parseSgrMouse(
      List<int> bytes, int i, StreamController<InputEvent> controller) {
    final buf = StringBuffer();
    while (i < bytes.length &&
        bytes[i] != 0x4D && // 'M' press
        bytes[i] != 0x6D) {
      // 'm' release
      buf.write(String.fromCharCode(bytes[i]));
      i++;
    }

    if (i >= bytes.length) return i;

    final isRelease = bytes[i] == 0x6D;
    i++;

    final parts = buf.toString().split(';');
    if (parts.length != 3) return i;

    final cb = int.tryParse(parts[0]) ?? 0;
    final cx = (int.tryParse(parts[1]) ?? 1) - 1; // Convert to 0-based
    final cy = (int.tryParse(parts[2]) ?? 1) - 1;

    MouseButton button;
    MouseAction action;

    final buttonBits = cb & 0x03;
    final isDrag = cb & 0x20 != 0;

    if (cb & 0x40 != 0) {
      // Scroll
      button = buttonBits == 0 ? MouseButton.scrollUp : MouseButton.scrollDown;
      action = MouseAction.press;
    } else if (isDrag) {
      switch (buttonBits) {
        case 0:
          button = MouseButton.left;
        case 1:
          button = MouseButton.middle;
        case 2:
          button = MouseButton.right;
        default:
          button = MouseButton.none;
      }
      action = MouseAction.drag;
    } else if (isRelease) {
      switch (buttonBits) {
        case 0:
          button = MouseButton.left;
        case 1:
          button = MouseButton.middle;
        case 2:
          button = MouseButton.right;
        default:
          button = MouseButton.none;
      }
      action = MouseAction.release;
    } else {
      switch (buttonBits) {
        case 0:
          button = MouseButton.left;
        case 1:
          button = MouseButton.middle;
        case 2:
          button = MouseButton.right;
        default:
          button = MouseButton.none;
      }
      action = MouseAction.press;
    }

    controller.add(MouseEvent(cx, cy, button, action));
    return i;
  }

  /// Decode a single UTF-8 byte sequence into a list of code units.
  static List<int> _decodeUtf8(List<int> bytes) {
    if (bytes.isEmpty) return [];
    int codePoint;
    if (bytes.length == 2) {
      codePoint = ((bytes[0] & 0x1F) << 6) | (bytes[1] & 0x3F);
    } else if (bytes.length == 3) {
      codePoint = ((bytes[0] & 0x0F) << 12) |
          ((bytes[1] & 0x3F) << 6) |
          (bytes[2] & 0x3F);
    } else if (bytes.length == 4) {
      codePoint = ((bytes[0] & 0x07) << 18) |
          ((bytes[1] & 0x3F) << 12) |
          ((bytes[2] & 0x3F) << 6) |
          (bytes[3] & 0x3F);
    } else {
      return [];
    }
    return String.fromCharCode(codePoint).codeUnits;
  }
}
