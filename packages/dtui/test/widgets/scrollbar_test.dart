import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('Scrollbar', () {
    late Buffer buffer;
    late Canvas canvas;
    const area = Rect(0, 0, 1, 10);

    setUp(() {
      buffer = Buffer(1, 10);
      canvas = Canvas(buffer, area);
    });

    test('thumb size proportional to visible/total ratio', () {
      final sb = Scrollbar(
        totalItems: 20,
        visibleItems: 10,
        scrollOffset: 0,
      );
      sb.render(canvas, area);
      // Track height = 10, visible/total = 10/20 = 0.5
      // Thumb height = ceil(10 * 10/20) = 5
      var thumbCount = 0;
      for (var y = 0; y < 10; y++) {
        if (buffer.getCell(0, y).char == Scrollbar.thumbChar) {
          thumbCount++;
        }
      }
      expect(thumbCount, 5);
    });

    test('thumb at top when scrollOffset is 0', () {
      final sb = Scrollbar(
        totalItems: 20,
        visibleItems: 10,
        scrollOffset: 0,
      );
      sb.render(canvas, area);
      expect(buffer.getCell(0, 0).char, Scrollbar.thumbChar);
    });

    test('thumb at bottom when scrolled to end', () {
      final sb = Scrollbar(
        totalItems: 20,
        visibleItems: 10,
        scrollOffset: 10, // maxOffset = 20-10 = 10
      );
      sb.render(canvas, area);
      expect(buffer.getCell(0, 9).char, Scrollbar.thumbChar);
    });

    test('all items fit shows only track', () {
      final sb = Scrollbar(
        totalItems: 5,
        visibleItems: 10,
        scrollOffset: 0,
      );
      sb.render(canvas, area);
      for (var y = 0; y < 10; y++) {
        expect(buffer.getCell(0, y).char, Scrollbar.trackChar);
      }
    });

    test('measure returns width of 1', () {
      final sb = Scrollbar(
        totalItems: 20,
        visibleItems: 10,
        scrollOffset: 0,
      );
      final (w, _) = sb.measure(const BoxConstraints.loose(5, 10));
      expect(w, 1);
    });

    test('no event handling (returns false)', () {
      final sb = Scrollbar(
        totalItems: 20,
        visibleItems: 10,
        scrollOffset: 0,
      );
      expect(sb.handleEvent(const KeyEvent('j')), false);
    });
  });
}
