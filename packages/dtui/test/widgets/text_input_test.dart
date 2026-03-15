import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('TextInput', () {
    late Buffer buffer;
    late Canvas canvas;
    const area = Rect(0, 0, 30, 1);

    setUp(() {
      buffer = Buffer(30, 1);
      canvas = Canvas(buffer, area);
    });

    test('renders text with cursor', () {
      final input = TextInput(text: 'Hi');
      input.render(canvas, area);
      expect(buffer.getCell(0, 0).char, 'H');
      expect(buffer.getCell(1, 0).char, 'i');
      // Cursor at position 2 (end of text) - should be inverse space
      expect(buffer.getCell(2, 0).style.inverse, true);
    });

    test('character insertion at cursor position', () {
      final input = TextInput(text: 'ac');
      // Move cursor to position 1 (between a and c)
      input.handleEvent(const KeyEvent(keyHome));
      input.handleEvent(const KeyEvent(keyRight));
      input.handleEvent(const KeyEvent('b'));
      expect(input.text, 'abc');
      expect(input.cursorPosition, 2);
    });

    test('backspace deletes character before cursor', () {
      final input = TextInput(text: 'abc');
      input.handleEvent(const KeyEvent(keyBackspace));
      expect(input.text, 'ab');
      expect(input.cursorPosition, 2);
    });

    test('backspace at beginning does nothing', () {
      final input = TextInput(text: 'abc');
      input.handleEvent(const KeyEvent(keyHome));
      input.handleEvent(const KeyEvent(keyBackspace));
      expect(input.text, 'abc');
      expect(input.cursorPosition, 0);
    });

    test('delete removes character at cursor', () {
      final input = TextInput(text: 'abc');
      input.handleEvent(const KeyEvent(keyHome));
      input.handleEvent(const KeyEvent(keyDelete));
      expect(input.text, 'bc');
      expect(input.cursorPosition, 0);
    });

    test('delete at end does nothing', () {
      final input = TextInput(text: 'abc');
      input.handleEvent(const KeyEvent(keyDelete));
      expect(input.text, 'abc');
    });

    test('left/right cursor movement', () {
      final input = TextInput(text: 'abc');
      expect(input.cursorPosition, 3);
      input.handleEvent(const KeyEvent(keyLeft));
      expect(input.cursorPosition, 2);
      input.handleEvent(const KeyEvent(keyLeft));
      expect(input.cursorPosition, 1);
      input.handleEvent(const KeyEvent(keyRight));
      expect(input.cursorPosition, 2);
    });

    test('left at beginning does not go below 0', () {
      final input = TextInput(text: 'abc');
      input.handleEvent(const KeyEvent(keyHome));
      input.handleEvent(const KeyEvent(keyLeft));
      expect(input.cursorPosition, 0);
    });

    test('right at end does not exceed text length', () {
      final input = TextInput(text: 'abc');
      input.handleEvent(const KeyEvent(keyRight));
      expect(input.cursorPosition, 3);
    });

    test('Home jumps to beginning', () {
      final input = TextInput(text: 'abc');
      input.handleEvent(const KeyEvent(keyHome));
      expect(input.cursorPosition, 0);
    });

    test('End jumps to end', () {
      final input = TextInput(text: 'abc');
      input.handleEvent(const KeyEvent(keyHome));
      input.handleEvent(const KeyEvent(keyEnd));
      expect(input.cursorPosition, 3);
    });

    test('Enter triggers onSubmit', () {
      String? submitted;
      final input = TextInput(
        text: 'hello',
        onSubmit: (val) => submitted = val,
      );
      input.handleEvent(const KeyEvent(keyEnter));
      expect(submitted, 'hello');
    });

    test('onChange called on text modification', () {
      String? changed;
      final input = TextInput(
        text: 'ab',
        onChange: (val) => changed = val,
      );
      input.handleEvent(const KeyEvent('c'));
      expect(changed, 'abc');
    });

    test('onChange called on backspace', () {
      String? changed;
      final input = TextInput(
        text: 'abc',
        onChange: (val) => changed = val,
      );
      input.handleEvent(const KeyEvent(keyBackspace));
      expect(changed, 'ab');
    });

    test('prompt prefix rendering', () {
      final input = TextInput(text: 'hi', prompt: '> ');
      input.render(canvas, area);
      expect(buffer.getCell(0, 0).char, '>');
      expect(buffer.getCell(1, 0).char, ' ');
      expect(buffer.getCell(2, 0).char, 'h');
      expect(buffer.getCell(3, 0).char, 'i');
    });

    test('space key inserts space', () {
      final input = TextInput(text: 'ab');
      input.handleEvent(const KeyEvent(keyHome));
      input.handleEvent(const KeyEvent(keyRight));
      input.handleEvent(const KeyEvent(keySpace));
      expect(input.text, 'a b');
    });

    test('ctrl+key does not insert character', () {
      final input = TextInput(text: 'ab');
      final result = input.handleEvent(const KeyEvent('c', ctrl: true));
      expect(result, false);
      expect(input.text, 'ab');
    });

    test('measure includes prompt, text, and cursor', () {
      final input = TextInput(text: 'abc', prompt: '> ');
      final (w, h) = input.measure(const BoxConstraints());
      expect(w, 6); // "> " (2) + "abc" (3) + cursor (1)
      expect(h, 1);
    });
  });
}
