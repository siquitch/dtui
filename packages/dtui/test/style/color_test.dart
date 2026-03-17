import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('Color', () {
    group('16 ANSI color constants', () {
      test('all 16 constants exist and are distinct', () {
        final colors = [
          Color.black,
          Color.red,
          Color.green,
          Color.yellow,
          Color.blue,
          Color.magenta,
          Color.cyan,
          Color.white,
          Color.brightBlack,
          Color.brightRed,
          Color.brightGreen,
          Color.brightYellow,
          Color.brightBlue,
          Color.brightMagenta,
          Color.brightCyan,
          Color.brightWhite,
        ];
        expect(colors.toSet().length, 16);
      });
    });

    group('Color.ansi()', () {
      test('index 0-7 produce standard foreground codes 30-37', () {
        expect(Color.ansi(0).toForegroundCode(), '30');
        expect(Color.ansi(7).toForegroundCode(), '37');
      });

      test('index 8-15 produce bright foreground codes 90-97', () {
        expect(Color.ansi(8).toForegroundCode(), '90');
        expect(Color.ansi(15).toForegroundCode(), '97');
      });

      test('index 0-7 produce standard background codes 40-47', () {
        expect(Color.ansi(0).toBackgroundCode(), '40');
        expect(Color.ansi(7).toBackgroundCode(), '47');
      });

      test('index 8-15 produce bright background codes 100-107', () {
        expect(Color.ansi(8).toBackgroundCode(), '100');
        expect(Color.ansi(15).toBackgroundCode(), '107');
      });

      test('index 16+ produce 256-color foreground codes', () {
        expect(Color.ansi(16).toForegroundCode(), '38;5;16');
        expect(Color.ansi(255).toForegroundCode(), '38;5;255');
      });

      test('index 16+ produce 256-color background codes', () {
        expect(Color.ansi(16).toBackgroundCode(), '48;5;16');
        expect(Color.ansi(255).toBackgroundCode(), '48;5;255');
      });
    });

    group('Color.rgb()', () {
      test('produces correct 24-bit foreground escape codes', () {
        expect(Color.rgb(255, 128, 0).toForegroundCode(), '38;2;255;128;0');
      });

      test('produces correct 24-bit background escape codes', () {
        expect(Color.rgb(255, 128, 0).toBackgroundCode(), '48;2;255;128;0');
      });

      test('boundary values (0,0,0) and (255,255,255)', () {
        expect(Color.rgb(0, 0, 0).toForegroundCode(), '38;2;0;0;0');
        expect(Color.rgb(255, 255, 255).toForegroundCode(), '38;2;255;255;255');
      });
    });

    group('Color.reset', () {
      test('produces foreground reset code', () {
        expect(Color.reset.toForegroundCode(), '39');
      });

      test('produces background reset code', () {
        expect(Color.reset.toBackgroundCode(), '49');
      });
    });

    group('equality', () {
      test('same construction produces equal colors', () {
        expect(Color.ansi(42), Color.ansi(42));
        expect(Color.rgb(10, 20, 30), Color.rgb(10, 20, 30));
      });

      test('different construction produces unequal colors', () {
        expect(Color.ansi(42), isNot(Color.ansi(43)));
        expect(Color.rgb(10, 20, 30), isNot(Color.rgb(10, 20, 31)));
      });

      test('ansi16 constant equals Color.ansi() for same index', () {
        expect(Color.black, Color.ansi(0));
        expect(Color.brightWhite, Color.ansi(15));
      });

      test('hashCode is consistent with equality', () {
        expect(Color.ansi(42).hashCode, Color.ansi(42).hashCode);
        expect(Color.rgb(10, 20, 30).hashCode, Color.rgb(10, 20, 30).hashCode);
      });
    });
  });
}
