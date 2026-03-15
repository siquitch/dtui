import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('Canvas', () {
    late Buffer buffer;
    late Canvas canvas;

    setUp(() {
      buffer = Buffer(20, 10);
      canvas = Canvas(buffer, const Rect(0, 0, 20, 10));
    });

    group('drawText', () {
      test('writes to underlying buffer at correct position', () {
        canvas.drawText(2, 3, 'Hi', Style.none);
        expect(buffer.getCell(2, 3).char, 'H');
        expect(buffer.getCell(3, 3).char, 'i');
      });

      test('clipped by canvas clip rect', () {
        final clipped = Canvas(buffer, const Rect(5, 0, 10, 10));
        clipped.drawText(3, 0, 'Hello', Style.none);
        // Characters at x=3 and x=4 are outside clip (left=5)
        expect(buffer.getCell(3, 0), Cell.empty);
        expect(buffer.getCell(4, 0), Cell.empty);
        // Characters at x=5,6,7 are inside clip
        expect(buffer.getCell(5, 0).char, 'l');
        expect(buffer.getCell(6, 0).char, 'l');
        expect(buffer.getCell(7, 0).char, 'o');
      });

      test('y outside clip is ignored', () {
        final clipped = Canvas(buffer, const Rect(0, 2, 20, 5));
        clipped.drawText(0, 1, 'Hi', Style.none);
        expect(buffer.getCell(0, 1), Cell.empty);
      });
    });

    group('drawChar', () {
      test('single character placement', () {
        canvas.drawChar(5, 5, 'X', Style.none);
        expect(buffer.getCell(5, 5).char, 'X');
      });

      test('outside clip is ignored', () {
        final clipped = Canvas(buffer, const Rect(5, 5, 5, 5));
        clipped.drawChar(4, 5, 'X', Style.none);
        expect(buffer.getCell(4, 5), Cell.empty);
      });
    });

    group('fillRect', () {
      test('fills within clip', () {
        const cell = Cell('#', Style.none);
        canvas.fillRect(const Rect(1, 1, 3, 3), cell);
        for (var y = 1; y < 4; y++) {
          for (var x = 1; x < 4; x++) {
            expect(buffer.getCell(x, y), cell);
          }
        }
      });

      test('clipped to canvas rect', () {
        final clipped = Canvas(buffer, const Rect(5, 5, 5, 5));
        const cell = Cell('#', Style.none);
        clipped.fillRect(const Rect(3, 3, 10, 10), cell);
        // Only the intersection (5,5)-(10,10) should be filled
        expect(buffer.getCell(4, 5), Cell.empty);
        expect(buffer.getCell(5, 5), cell);
        expect(buffer.getCell(9, 9), cell);
      });
    });

    group('drawHorizontalLine', () {
      test('correct placement and length', () {
        canvas.drawHorizontalLine(2, 3, 5, '-', Style.none);
        for (var x = 2; x < 7; x++) {
          expect(buffer.getCell(x, 3).char, '-');
        }
        expect(buffer.getCell(1, 3), Cell.empty);
        expect(buffer.getCell(7, 3), Cell.empty);
      });
    });

    group('drawVerticalLine', () {
      test('correct placement and length', () {
        canvas.drawVerticalLine(3, 2, 4, '|', Style.none);
        for (var y = 2; y < 6; y++) {
          expect(buffer.getCell(3, y).char, '|');
        }
        expect(buffer.getCell(3, 1), Cell.empty);
        expect(buffer.getCell(3, 6), Cell.empty);
      });
    });

    group('drawBox', () {
      test('corners and edges placed correctly', () {
        const chars = BoxChars.single();
        canvas.drawBox(const Rect(0, 0, 5, 3), chars, Style.none);
        // Corners
        expect(buffer.getCell(0, 0).char, chars.topLeft);
        expect(buffer.getCell(4, 0).char, chars.topRight);
        expect(buffer.getCell(0, 2).char, chars.bottomLeft);
        expect(buffer.getCell(4, 2).char, chars.bottomRight);
        // Horizontal edges
        for (var x = 1; x < 4; x++) {
          expect(buffer.getCell(x, 0).char, chars.horizontal);
          expect(buffer.getCell(x, 2).char, chars.horizontal);
        }
        // Vertical edges
        expect(buffer.getCell(0, 1).char, chars.vertical);
        expect(buffer.getCell(4, 1).char, chars.vertical);
      });

      test('too small rect (< 2) is ignored', () {
        const chars = BoxChars.single();
        canvas.drawBox(const Rect(0, 0, 1, 1), chars, Style.none);
        expect(buffer.getCell(0, 0), Cell.empty);
      });
    });

    group('subCanvas', () {
      test('further restricts clip rect (intersection)', () {
        final parent = Canvas(buffer, const Rect(2, 2, 10, 10));
        final sub = parent.subCanvas(const Rect(5, 5, 10, 10));
        // Intersection of (2,2,10,10) and (5,5,10,10) = (5,5,7,7)
        expect(sub.clip, const Rect(5, 5, 7, 7));
      });

      test('coordinates are buffer-relative', () {
        final sub = canvas.subCanvas(const Rect(5, 5, 5, 5));
        sub.drawChar(5, 5, 'X', Style.none);
        expect(buffer.getCell(5, 5).char, 'X');
      });
    });
  });
}
