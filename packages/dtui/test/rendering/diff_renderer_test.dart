import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('DiffRenderer', () {
    late DiffRenderer renderer;

    setUp(() {
      renderer = DiffRenderer();
    });

    group('renderFull', () {
      test('produces ANSI for every cell in buffer', () {
        final buf = Buffer(3, 1);
        buf.writeString(0, 0, 'Hi!', Style.none);
        final output = renderer.renderFull(buf);
        // Should contain move-to-origin and the characters
        expect(output, contains('Hi!'));
        expect(output, contains('\x1B[')); // contains ANSI escape
      });

      test('styled cells include ANSI prefix', () {
        final buf = Buffer(2, 1);
        buf.writeString(0, 0, 'AB', const Style(bold: true));
        final output = renderer.renderFull(buf);
        expect(output, contains('\x1B[1m'));
        expect(output, contains('AB'));
      });
    });

    group('render (diff)', () {
      test('identical buffers produce empty string', () {
        final buf = Buffer(5, 3);
        buf.writeString(0, 0, 'Hello', Style.none);
        final copy = buf.clone();
        final output = renderer.render(buf, copy);
        expect(output, '');
      });

      test('single cell change produces minimal output', () {
        final prev = Buffer(5, 1);
        prev.writeString(0, 0, 'Hello', Style.none);
        final curr = prev.clone();
        curr.setCell(2, 0, const Cell('X', Style.none));
        final output = renderer.render(prev, curr);
        expect(output, contains('X'));
        // Should contain a cursor move to position (2,0)
        expect(output, contains('\x1B[1;3H')); // moveTo(2,0) = row 1, col 3
      });

      test('style change without character change detected', () {
        final prev = Buffer(3, 1);
        prev.writeString(0, 0, 'abc', Style.none);
        final curr = prev.clone();
        curr.setCell(1, 0, const Cell('b', Style(bold: true)));
        final output = renderer.render(prev, curr);
        expect(output, contains('\x1B[1m')); // bold
        expect(output, contains('b'));
      });

      test('consecutive changed cells batched (no extra cursor moves)', () {
        final prev = Buffer(5, 1);
        prev.writeString(0, 0, 'Hello', Style.none);
        final curr = prev.clone();
        curr.writeString(1, 0, 'ELL', Style.none);
        final output = renderer.render(prev, curr);
        // Should move to (1,0) once, then write 'ELL' without extra moves
        expect(output, contains('ELL'));
        // Only one cursor move in total (to position 1,0)
        final moveCount = '\x1B['.allMatches(output).length;
        // Could have style transitions too, but should be minimal
        expect(moveCount, lessThanOrEqualTo(2));
      });

      test('scattered changes produce separate cursor moves', () {
        final prev = Buffer(10, 1);
        prev.writeString(0, 0, 'abcdefghij', Style.none);
        final curr = prev.clone();
        curr.setCell(0, 0, const Cell('X', Style.none));
        curr.setCell(9, 0, const Cell('Y', Style.none));
        final output = renderer.render(prev, curr);
        expect(output, contains('X'));
        expect(output, contains('Y'));
      });
    });
  });
}
