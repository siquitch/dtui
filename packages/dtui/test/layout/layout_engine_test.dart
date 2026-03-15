import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('LayoutEngine.split', () {
    const area = Rect(0, 0, 100, 50);

    group('horizontal', () {
      test('equal flex specs divide evenly', () {
        final rects = LayoutEngine.split(
          area,
          SplitDirection.horizontal,
          [const SplitSpec.flex(1), const SplitSpec.flex(1)],
        );
        expect(rects.length, 2);
        expect(rects[0], const Rect(0, 0, 50, 50));
        expect(rects[1], const Rect(50, 0, 50, 50));
      });

      test('unequal flex ratios 1:2', () {
        final rects = LayoutEngine.split(
          area,
          SplitDirection.horizontal,
          [const SplitSpec.flex(1), const SplitSpec.flex(2)],
        );
        expect(rects.length, 2);
        expect(rects[0].width, 33);
        // Last rect absorbs remainder
        expect(rects[1].width, 67);
        expect(rects[0].x + rects[0].width, rects[1].x);
      });

      test('fixed specs consume exact space', () {
        final rects = LayoutEngine.split(
          area,
          SplitDirection.horizontal,
          [const SplitSpec.fixed(30), const SplitSpec.fixed(20)],
        );
        expect(rects[0].width, 30);
        // Last rect absorbs remainder: 100 - 30 = 70
        expect(rects[1].width, 70);
        expect(rects[0].x, 0);
        expect(rects[1].x, 30);
      });

      test('mixed fixed + flex: fixed consumed first', () {
        final rects = LayoutEngine.split(
          area,
          SplitDirection.horizontal,
          [
            const SplitSpec.fixed(20),
            const SplitSpec.flex(1),
            const SplitSpec.flex(1),
          ],
        );
        expect(rects[0].width, 20);
        // Remaining 80 split between two flex
        expect(rects[1].width, 40);
        expect(rects[2].width, 40);
      });

      test('single spec fills entire area', () {
        final rects = LayoutEngine.split(
          area,
          SplitDirection.horizontal,
          [const SplitSpec.flex(1)],
        );
        expect(rects.length, 1);
        expect(rects[0], area);
      });
    });

    group('vertical', () {
      test('equal flex specs divide evenly', () {
        final rects = LayoutEngine.split(
          area,
          SplitDirection.vertical,
          [const SplitSpec.flex(1), const SplitSpec.flex(1)],
        );
        expect(rects[0], const Rect(0, 0, 100, 25));
        expect(rects[1], const Rect(0, 25, 100, 25));
      });

      test('mixed fixed + flex', () {
        final rects = LayoutEngine.split(
          area,
          SplitDirection.vertical,
          [const SplitSpec.fixed(10), const SplitSpec.flex(1)],
        );
        expect(rects[0].height, 10);
        expect(rects[1].height, 40);
      });
    });

    group('edge cases', () {
      test('empty specs returns empty list', () {
        final rects = LayoutEngine.split(
          area,
          SplitDirection.horizontal,
          [],
        );
        expect(rects, isEmpty);
      });

      test('rounding: last rect absorbs remainder', () {
        const oddArea = Rect(0, 0, 100, 50);
        final rects = LayoutEngine.split(
          oddArea,
          SplitDirection.horizontal,
          [
            const SplitSpec.flex(1),
            const SplitSpec.flex(1),
            const SplitSpec.flex(1),
          ],
        );
        // 100/3 = 33.33... so rounded: 33, 33, last absorbs to fill to 100
        final totalWidth = rects.fold<int>(0, (sum, r) => sum + r.width);
        expect(totalWidth, 100);
        expect(rects.last.x + rects.last.width, 100);
      });

      test('zero-width area', () {
        const zeroArea = Rect(0, 0, 0, 50);
        final rects = LayoutEngine.split(
          zeroArea,
          SplitDirection.horizontal,
          [const SplitSpec.flex(1), const SplitSpec.flex(1)],
        );
        expect(rects.length, 2);
        for (final r in rects) {
          expect(r.width, 0);
        }
      });
    });
  });
}
