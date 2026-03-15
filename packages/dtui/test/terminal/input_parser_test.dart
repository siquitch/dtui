import 'dart:async';

import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

/// Helper to parse a single byte sequence and return all events.
Future<List<InputEvent>> parseBytes(List<int> bytes) async {
  final parser = InputParser();
  final controller = StreamController<List<int>>();
  final events = <InputEvent>[];
  final subscription = parser.parse(controller.stream).listen(events.add);
  controller.add(bytes);
  await controller.close();
  await subscription.asFuture<void>();
  return events;
}

void main() {
  group('InputParser', () {
    group('printable ASCII', () {
      test('lowercase letter', () async {
        final events = await parseBytes([0x61]); // 'a'
        expect(events, hasLength(1));
        final e = events[0] as KeyEvent;
        expect(e.key, 'a');
        expect(e.ctrl, false);
        expect(e.alt, false);
      });

      test('uppercase letter', () async {
        final events = await parseBytes([0x41]); // 'A'
        expect(events, hasLength(1));
        expect((events[0] as KeyEvent).key, 'A');
      });

      test('digit', () async {
        final events = await parseBytes([0x35]); // '5'
        expect((events[0] as KeyEvent).key, '5');
      });

      test('symbol', () async {
        final events = await parseBytes([0x2F]); // '/'
        expect((events[0] as KeyEvent).key, '/');
      });
    });

    group('special keys', () {
      test('Enter (CR)', () async {
        final events = await parseBytes([0x0D]);
        expect((events[0] as KeyEvent).key, keyEnter);
      });

      test('Enter (LF)', () async {
        final events = await parseBytes([0x0A]);
        expect((events[0] as KeyEvent).key, keyEnter);
      });

      test('Tab', () async {
        final events = await parseBytes([0x09]);
        expect((events[0] as KeyEvent).key, keyTab);
      });

      test('Backspace (0x7F)', () async {
        final events = await parseBytes([0x7F]);
        expect((events[0] as KeyEvent).key, keyBackspace);
      });

      test('Backspace (0x08)', () async {
        final events = await parseBytes([0x08]);
        expect((events[0] as KeyEvent).key, keyBackspace);
      });

      test('Space', () async {
        final events = await parseBytes([0x20]);
        expect((events[0] as KeyEvent).key, keySpace);
      });

      test('Escape (lone)', () async {
        final events = await parseBytes([0x1B]);
        expect((events[0] as KeyEvent).key, keyEscape);
      });
    });

    group('Ctrl+letter', () {
      test('Ctrl+A', () async {
        final events = await parseBytes([0x01]);
        final e = events[0] as KeyEvent;
        expect(e.key, 'a');
        expect(e.ctrl, true);
      });

      test('Ctrl+C', () async {
        final events = await parseBytes([0x03]);
        final e = events[0] as KeyEvent;
        expect(e.key, 'c');
        expect(e.ctrl, true);
      });

      test('Ctrl+Z', () async {
        final events = await parseBytes([0x1A]);
        final e = events[0] as KeyEvent;
        expect(e.key, 'z');
        expect(e.ctrl, true);
      });
    });

    group('arrow keys', () {
      test('Up', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x41]);
        expect((events[0] as KeyEvent).key, keyUp);
      });

      test('Down', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x42]);
        expect((events[0] as KeyEvent).key, keyDown);
      });

      test('Right', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x43]);
        expect((events[0] as KeyEvent).key, keyRight);
      });

      test('Left', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x44]);
        expect((events[0] as KeyEvent).key, keyLeft);
      });
    });

    group('navigation keys', () {
      test('Home (CSI H)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x48]);
        expect((events[0] as KeyEvent).key, keyHome);
      });

      test('End (CSI F)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x46]);
        expect((events[0] as KeyEvent).key, keyEnd);
      });

      test('Home (CSI 1~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x31, 0x7E]);
        expect((events[0] as KeyEvent).key, keyHome);
      });

      test('End (CSI 4~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x34, 0x7E]);
        expect((events[0] as KeyEvent).key, keyEnd);
      });

      test('Delete (CSI 3~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x33, 0x7E]);
        expect((events[0] as KeyEvent).key, keyDelete);
      });

      test('PageUp (CSI 5~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x35, 0x7E]);
        expect((events[0] as KeyEvent).key, keyPageUp);
      });

      test('PageDown (CSI 6~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x36, 0x7E]);
        expect((events[0] as KeyEvent).key, keyPageDown);
      });
    });

    group('function keys', () {
      test('F1 (SS3 P)', () async {
        final events = await parseBytes([0x1B, 0x4F, 0x50]);
        expect((events[0] as KeyEvent).key, keyF1);
      });

      test('F2 (SS3 Q)', () async {
        final events = await parseBytes([0x1B, 0x4F, 0x51]);
        expect((events[0] as KeyEvent).key, keyF2);
      });

      test('F3 (SS3 R)', () async {
        final events = await parseBytes([0x1B, 0x4F, 0x52]);
        expect((events[0] as KeyEvent).key, keyF3);
      });

      test('F4 (SS3 S)', () async {
        final events = await parseBytes([0x1B, 0x4F, 0x53]);
        expect((events[0] as KeyEvent).key, keyF4);
      });

      test('F5 (CSI 15~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x31, 0x35, 0x7E]);
        expect((events[0] as KeyEvent).key, keyF5);
      });

      test('F6 (CSI 17~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x31, 0x37, 0x7E]);
        expect((events[0] as KeyEvent).key, keyF6);
      });

      test('F7 (CSI 18~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x31, 0x38, 0x7E]);
        expect((events[0] as KeyEvent).key, keyF7);
      });

      test('F8 (CSI 19~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x31, 0x39, 0x7E]);
        expect((events[0] as KeyEvent).key, keyF8);
      });

      test('F9 (CSI 20~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x32, 0x30, 0x7E]);
        expect((events[0] as KeyEvent).key, keyF9);
      });

      test('F10 (CSI 21~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x32, 0x31, 0x7E]);
        expect((events[0] as KeyEvent).key, keyF10);
      });

      test('F11 (CSI 23~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x32, 0x33, 0x7E]);
        expect((events[0] as KeyEvent).key, keyF11);
      });

      test('F12 (CSI 24~)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x32, 0x34, 0x7E]);
        expect((events[0] as KeyEvent).key, keyF12);
      });
    });

    group('modifier combinations', () {
      test('Shift+Up (CSI 1;2A)', () async {
        // ESC [ 1 ; 2 A
        final events =
            await parseBytes([0x1B, 0x5B, 0x31, 0x3B, 0x32, 0x41]);
        final e = events[0] as KeyEvent;
        expect(e.key, keyUp);
        expect(e.shift, true);
        expect(e.alt, false);
        expect(e.ctrl, false);
      });

      test('Alt+Right (CSI 1;3C)', () async {
        final events =
            await parseBytes([0x1B, 0x5B, 0x31, 0x3B, 0x33, 0x43]);
        final e = events[0] as KeyEvent;
        expect(e.key, keyRight);
        expect(e.alt, true);
      });

      test('Ctrl+Left (CSI 1;5D)', () async {
        final events =
            await parseBytes([0x1B, 0x5B, 0x31, 0x3B, 0x35, 0x44]);
        final e = events[0] as KeyEvent;
        expect(e.key, keyLeft);
        expect(e.ctrl, true);
      });

      test('Shift+Alt+Ctrl (modifier 8 = 1+1+2+4)', () async {
        // CSI 1;8A = Shift+Alt+Ctrl+Up
        final events =
            await parseBytes([0x1B, 0x5B, 0x31, 0x3B, 0x38, 0x41]);
        final e = events[0] as KeyEvent;
        expect(e.key, keyUp);
        expect(e.shift, true);
        expect(e.alt, true);
        expect(e.ctrl, true);
      });

      test('Shift+Tab (CSI Z)', () async {
        final events = await parseBytes([0x1B, 0x5B, 0x5A]);
        final e = events[0] as KeyEvent;
        expect(e.key, keyTab);
        expect(e.shift, true);
      });

      test('Alt+letter', () async {
        // ESC a
        final events = await parseBytes([0x1B, 0x61]);
        final e = events[0] as KeyEvent;
        expect(e.key, 'a');
        expect(e.alt, true);
      });

      test('Alt+Shift+letter', () async {
        // ESC A (uppercase = shift)
        final events = await parseBytes([0x1B, 0x41]);
        final e = events[0] as KeyEvent;
        expect(e.key, 'a');
        expect(e.alt, true);
        expect(e.shift, true);
      });
    });

    group('SGR mouse', () {
      test('left button press', () async {
        // ESC [ < 0 ; 10 ; 20 M
        final bytes = [
          0x1B, 0x5B, 0x3C, // ESC [ <
          0x30, 0x3B, 0x31, 0x30, 0x3B, 0x32, 0x30, // 0;10;20
          0x4D, // M (press)
        ];
        final events = await parseBytes(bytes);
        final e = events[0] as MouseEvent;
        expect(e.button, MouseButton.left);
        expect(e.action, MouseAction.press);
        expect(e.x, 9); // 10-1 = 9 (0-based)
        expect(e.y, 19); // 20-1 = 19
      });

      test('left button release', () async {
        // ESC [ < 0 ; 5 ; 5 m
        final bytes = [
          0x1B, 0x5B, 0x3C,
          0x30, 0x3B, 0x35, 0x3B, 0x35, // 0;5;5
          0x6D, // m (release)
        ];
        final events = await parseBytes(bytes);
        final e = events[0] as MouseEvent;
        expect(e.button, MouseButton.left);
        expect(e.action, MouseAction.release);
        expect(e.x, 4);
        expect(e.y, 4);
      });

      test('right button press', () async {
        // ESC [ < 2 ; 1 ; 1 M
        final bytes = [
          0x1B, 0x5B, 0x3C,
          0x32, 0x3B, 0x31, 0x3B, 0x31, // 2;1;1
          0x4D,
        ];
        final events = await parseBytes(bytes);
        final e = events[0] as MouseEvent;
        expect(e.button, MouseButton.right);
        expect(e.action, MouseAction.press);
      });

      test('middle button press', () async {
        // ESC [ < 1 ; 1 ; 1 M
        final bytes = [
          0x1B, 0x5B, 0x3C,
          0x31, 0x3B, 0x31, 0x3B, 0x31, // 1;1;1
          0x4D,
        ];
        final events = await parseBytes(bytes);
        final e = events[0] as MouseEvent;
        expect(e.button, MouseButton.middle);
      });

      test('scroll up', () async {
        // ESC [ < 64 ; 1 ; 1 M  (64 = 0x40 | 0)
        final bytes = [
          0x1B, 0x5B, 0x3C,
          0x36, 0x34, 0x3B, 0x31, 0x3B, 0x31, // 64;1;1
          0x4D,
        ];
        final events = await parseBytes(bytes);
        final e = events[0] as MouseEvent;
        expect(e.button, MouseButton.scrollUp);
      });

      test('scroll down', () async {
        // ESC [ < 65 ; 1 ; 1 M  (64 | 1)
        final bytes = [
          0x1B, 0x5B, 0x3C,
          0x36, 0x35, 0x3B, 0x31, 0x3B, 0x31, // 65;1;1
          0x4D,
        ];
        final events = await parseBytes(bytes);
        final e = events[0] as MouseEvent;
        expect(e.button, MouseButton.scrollDown);
      });

      test('drag', () async {
        // ESC [ < 32 ; 10 ; 20 M  (32 = 0x20 | 0 = left drag)
        final bytes = [
          0x1B, 0x5B, 0x3C,
          0x33, 0x32, 0x3B, 0x31, 0x30, 0x3B, 0x32, 0x30, // 32;10;20
          0x4D,
        ];
        final events = await parseBytes(bytes);
        final e = events[0] as MouseEvent;
        expect(e.button, MouseButton.left);
        expect(e.action, MouseAction.drag);
      });
    });

    group('UTF-8 multi-byte', () {
      test('2-byte character (e.g. ñ = 0xC3 0xB1)', () async {
        final events = await parseBytes([0xC3, 0xB1]);
        expect(events, hasLength(1));
        expect((events[0] as KeyEvent).key, 'ñ');
      });

      test('3-byte character (e.g. € = 0xE2 0x82 0xAC)', () async {
        final events = await parseBytes([0xE2, 0x82, 0xAC]);
        expect(events, hasLength(1));
        expect((events[0] as KeyEvent).key, '€');
      });
    });

    group('multiple events in one chunk', () {
      test('parses multiple printable characters', () async {
        final events = await parseBytes([0x61, 0x62, 0x63]); // a, b, c
        expect(events, hasLength(3));
        expect((events[0] as KeyEvent).key, 'a');
        expect((events[1] as KeyEvent).key, 'b');
        expect((events[2] as KeyEvent).key, 'c');
      });
    });
  });
}
