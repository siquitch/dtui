import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('Ansi', () {
    group('moveTo', () {
      test('converts 0-based to 1-based coordinates', () {
        expect(Ansi.moveTo(0, 0), '\x1B[1;1H');
        expect(Ansi.moveTo(5, 10), '\x1B[11;6H');
      });
    });

    group('movement methods', () {
      test('moveUp', () {
        expect(Ansi.moveUp(3), '\x1B[3A');
      });

      test('moveDown', () {
        expect(Ansi.moveDown(2), '\x1B[2B');
      });

      test('moveRight', () {
        expect(Ansi.moveRight(4), '\x1B[4C');
      });

      test('moveLeft', () {
        expect(Ansi.moveLeft(1), '\x1B[1D');
      });

      test('moveToNextLine', () {
        expect(Ansi.moveToNextLine(2), '\x1B[2E');
      });

      test('moveToPreviousLine', () {
        expect(Ansi.moveToPreviousLine(1), '\x1B[1F');
      });

      test('moveToColumn converts 0-based', () {
        expect(Ansi.moveToColumn(0), '\x1B[1G');
        expect(Ansi.moveToColumn(9), '\x1B[10G');
      });
    });

    group('clear methods', () {
      test('clearScreen', () {
        expect(Ansi.clearScreen(), '\x1B[2J');
      });

      test('clearToEndOfScreen', () {
        expect(Ansi.clearToEndOfScreen(), '\x1B[0J');
      });

      test('clearLine', () {
        expect(Ansi.clearLine(), '\x1B[2K');
      });

      test('clearToEndOfLine', () {
        expect(Ansi.clearToEndOfLine(), '\x1B[0K');
      });
    });

    group('cursor visibility', () {
      test('hideCursor', () {
        expect(Ansi.hideCursor(), '\x1B[?25l');
      });

      test('showCursor', () {
        expect(Ansi.showCursor(), '\x1B[?25h');
      });
    });

    group('resetStyle', () {
      test('produces SGR reset', () {
        expect(Ansi.resetStyle(), '\x1B[0m');
      });
    });

    group('screen buffer', () {
      test('enableAlternateScreen', () {
        expect(Ansi.enableAlternateScreen(), '\x1B[?1049h');
      });

      test('disableAlternateScreen', () {
        expect(Ansi.disableAlternateScreen(), '\x1B[?1049l');
      });
    });

    group('setTitle', () {
      test('produces OSC sequence', () {
        expect(Ansi.setTitle('My App'), '\x1B]0;My App\x1B\\');
      });
    });
  });
}
