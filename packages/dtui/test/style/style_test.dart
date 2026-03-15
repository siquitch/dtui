import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('Style', () {
    group('Style.none', () {
      test('has no attributes set', () {
        const s = Style.none;
        expect(s.foreground, isNull);
        expect(s.background, isNull);
        expect(s.bold, false);
        expect(s.dim, false);
        expect(s.italic, false);
        expect(s.underline, false);
        expect(s.strikethrough, false);
        expect(s.inverse, false);
      });

      test('toAnsiPrefix returns empty string', () {
        expect(Style.none.toAnsiPrefix(), '');
      });

      test('toAnsiSuffix returns empty string', () {
        expect(Style.none.toAnsiSuffix(), '');
      });
    });

    group('toAnsiPrefix', () {
      test('bold produces code 1', () {
        const s = Style(bold: true);
        expect(s.toAnsiPrefix(), '\x1B[1m');
      });

      test('dim produces code 2', () {
        const s = Style(dim: true);
        expect(s.toAnsiPrefix(), '\x1B[2m');
      });

      test('italic produces code 3', () {
        const s = Style(italic: true);
        expect(s.toAnsiPrefix(), '\x1B[3m');
      });

      test('underline produces code 4', () {
        const s = Style(underline: true);
        expect(s.toAnsiPrefix(), '\x1B[4m');
      });

      test('inverse produces code 7', () {
        const s = Style(inverse: true);
        expect(s.toAnsiPrefix(), '\x1B[7m');
      });

      test('strikethrough produces code 9', () {
        const s = Style(strikethrough: true);
        expect(s.toAnsiPrefix(), '\x1B[9m');
      });

      test('combined attributes produce all codes', () {
        const s = Style(bold: true, italic: true, underline: true);
        expect(s.toAnsiPrefix(), '\x1B[1;3;4m');
      });

      test('foreground color included in prefix', () {
        final s = Style(foreground: Color.red);
        expect(s.toAnsiPrefix(), '\x1B[31m');
      });

      test('background color included in prefix', () {
        final s = Style(background: Color.blue);
        expect(s.toAnsiPrefix(), '\x1B[44m');
      });

      test('all attributes combined', () {
        final s = Style(
          bold: true,
          dim: true,
          italic: true,
          underline: true,
          inverse: true,
          strikethrough: true,
          foreground: Color.red,
          background: Color.blue,
        );
        expect(s.toAnsiPrefix(), '\x1B[1;2;3;4;7;9;31;44m');
      });
    });

    group('toAnsiSuffix', () {
      test('any attribute set produces reset code', () {
        const s = Style(bold: true);
        expect(s.toAnsiSuffix(), '\x1B[0m');
      });

      test('foreground color produces reset code', () {
        final s = Style(foreground: Color.red);
        expect(s.toAnsiSuffix(), '\x1B[0m');
      });
    });

    group('merge', () {
      test('later style overrides foreground', () {
        final base = Style(foreground: Color.red);
        final overlay = Style(foreground: Color.blue);
        final merged = base.merge(overlay);
        expect(merged.foreground, Color.blue);
      });

      test('unset fields in overlay are preserved from base', () {
        final base = Style(foreground: Color.red, bold: true);
        const overlay = Style(italic: true);
        final merged = base.merge(overlay);
        expect(merged.foreground, Color.red);
        expect(merged.bold, true);
        expect(merged.italic, true);
      });

      test('boolean fields use OR logic', () {
        const base = Style(bold: true);
        const overlay = Style(italic: true);
        final merged = base.merge(overlay);
        expect(merged.bold, true);
        expect(merged.italic, true);
      });
    });

    group('copyWith', () {
      test('only specified fields change', () {
        final original = Style(foreground: Color.red, bold: true);
        final copied = original.copyWith(italic: true);
        expect(copied.foreground, Color.red);
        expect(copied.bold, true);
        expect(copied.italic, true);
      });

      test('can override foreground', () {
        final original = Style(foreground: Color.red);
        final copied = original.copyWith(foreground: Color.blue);
        expect(copied.foreground, Color.blue);
      });
    });

    group('equality and hashCode', () {
      test('identical styles are equal', () {
        const a = Style(bold: true, italic: true);
        const b = Style(bold: true, italic: true);
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('different styles are not equal', () {
        const a = Style(bold: true);
        const b = Style(italic: true);
        expect(a, isNot(b));
      });

      test('styles with same colors are equal', () {
        final a = Style(foreground: Color.red);
        final b = Style(foreground: Color.red);
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });
    });
  });
}
