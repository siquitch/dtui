import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('Buffer', () {
    test('constructor creates grid of Cell.empty', () {
      final buf = Buffer(5, 3);
      for (var y = 0; y < 3; y++) {
        for (var x = 0; x < 5; x++) {
          expect(buf.getCell(x, y), Cell.empty);
        }
      }
    });

    test('width and height match constructor args', () {
      final buf = Buffer(10, 20);
      expect(buf.width, 10);
      expect(buf.height, 20);
    });

    group('setCell / getCell', () {
      test('roundtrip', () {
        final buf = Buffer(5, 5);
        const cell = Cell('X', Style(bold: true));
        buf.setCell(2, 3, cell);
        expect(buf.getCell(2, 3), cell);
      });

      test('out-of-bounds getCell returns Cell.empty', () {
        final buf = Buffer(5, 5);
        expect(buf.getCell(-1, 0), Cell.empty);
        expect(buf.getCell(0, -1), Cell.empty);
        expect(buf.getCell(5, 0), Cell.empty);
        expect(buf.getCell(0, 5), Cell.empty);
      });

      test('out-of-bounds setCell is silently ignored', () {
        final buf = Buffer(5, 5);
        const cell = Cell('X', Style.none);
        buf.setCell(-1, 0, cell);
        buf.setCell(5, 0, cell);
        // No exception thrown
      });
    });

    group('writeString', () {
      test('writes characters with style at position', () {
        final buf = Buffer(10, 3);
        const style = Style(bold: true);
        buf.writeString(2, 1, 'Hi', style);
        expect(buf.getCell(2, 1), const Cell('H', style));
        expect(buf.getCell(3, 1), const Cell('i', style));
        // Adjacent cells untouched
        expect(buf.getCell(1, 1), Cell.empty);
        expect(buf.getCell(4, 1), Cell.empty);
      });

      test('stops at buffer edge (no overflow)', () {
        final buf = Buffer(5, 1);
        buf.writeString(3, 0, 'Hello', Style.none);
        expect(buf.getCell(3, 0).char, 'H');
        expect(buf.getCell(4, 0).char, 'e');
        // No crash, did not write beyond width
      });

      test('negative x start skips initial characters', () {
        final buf = Buffer(5, 1);
        buf.writeString(-2, 0, 'Hello', Style.none);
        expect(buf.getCell(0, 0).char, 'l');
        expect(buf.getCell(1, 0).char, 'l');
        expect(buf.getCell(2, 0).char, 'o');
      });

      test('out-of-bounds y is ignored', () {
        final buf = Buffer(5, 3);
        buf.writeString(0, -1, 'Hi', Style.none);
        buf.writeString(0, 3, 'Hi', Style.none);
        // No crash
      });
    });

    group('fill', () {
      test('fills rectangular region', () {
        final buf = Buffer(10, 10);
        const cell = Cell('#', Style.none);
        buf.fill(const Rect(2, 2, 3, 3), cell);
        for (var y = 2; y < 5; y++) {
          for (var x = 2; x < 5; x++) {
            expect(buf.getCell(x, y), cell);
          }
        }
        // Outside region untouched
        expect(buf.getCell(1, 2), Cell.empty);
        expect(buf.getCell(5, 2), Cell.empty);
      });
    });

    group('clear', () {
      test('resets all cells to empty', () {
        final buf = Buffer(5, 5);
        buf.setCell(2, 2, const Cell('X', Style.none));
        buf.clear();
        expect(buf.getCell(2, 2), Cell.empty);
      });
    });

    group('clone', () {
      test('produces equal but independent copy', () {
        final buf = Buffer(5, 5);
        buf.setCell(1, 1, const Cell('A', Style.none));
        final copy = buf.clone();
        expect(copy.getCell(1, 1), buf.getCell(1, 1));

        // Mutations don't propagate
        copy.setCell(1, 1, const Cell('B', Style.none));
        expect(buf.getCell(1, 1).char, 'A');
        expect(copy.getCell(1, 1).char, 'B');
      });

      test('clone dimensions match original', () {
        final buf = Buffer(7, 3);
        final copy = buf.clone();
        expect(copy.width, 7);
        expect(copy.height, 3);
      });
    });
  });
}
