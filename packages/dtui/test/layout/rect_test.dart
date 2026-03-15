import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('Rect', () {
    group('constructor', () {
      test('sets x, y, width, height correctly', () {
        const r = Rect(1, 2, 10, 20);
        expect(r.x, 1);
        expect(r.y, 2);
        expect(r.width, 10);
        expect(r.height, 20);
      });
    });

    group('fromLTRB', () {
      test('computes correct dimensions', () {
        final r = Rect.fromLTRB(5, 10, 25, 30);
        expect(r.x, 5);
        expect(r.y, 10);
        expect(r.width, 20);
        expect(r.height, 20);
      });
    });

    group('edge getters', () {
      test('left/top/right/bottom', () {
        const r = Rect(5, 10, 20, 30);
        expect(r.left, 5);
        expect(r.top, 10);
        expect(r.right, 25);
        expect(r.bottom, 40);
      });
    });

    group('contains', () {
      test('point inside returns true', () {
        const r = Rect(0, 0, 10, 10);
        expect(r.contains(5, 5), true);
      });

      test('point on left/top edge returns true', () {
        const r = Rect(0, 0, 10, 10);
        expect(r.contains(0, 0), true);
      });

      test('point on right/bottom edge returns false (exclusive)', () {
        const r = Rect(0, 0, 10, 10);
        expect(r.contains(10, 10), false);
        expect(r.contains(10, 5), false);
        expect(r.contains(5, 10), false);
      });

      test('point outside returns false', () {
        const r = Rect(0, 0, 10, 10);
        expect(r.contains(-1, 5), false);
        expect(r.contains(5, -1), false);
        expect(r.contains(11, 5), false);
      });
    });

    group('intersect', () {
      test('overlapping rects produce correct intersection', () {
        const a = Rect(0, 0, 10, 10);
        const b = Rect(5, 5, 10, 10);
        expect(a.intersect(b), const Rect(5, 5, 5, 5));
      });

      test('non-overlapping rects produce zero rect', () {
        const a = Rect(0, 0, 5, 5);
        const b = Rect(10, 10, 5, 5);
        final result = a.intersect(b);
        expect(result.width, 0);
        expect(result.height, 0);
      });

      test('contained rect returns the smaller rect', () {
        const outer = Rect(0, 0, 20, 20);
        const inner = Rect(5, 5, 5, 5);
        expect(outer.intersect(inner), inner);
      });

      test('identical rects return same rect', () {
        const r = Rect(3, 4, 10, 10);
        expect(r.intersect(r), r);
      });
    });

    group('deflate', () {
      test('shrinks correctly', () {
        const r = Rect(0, 0, 20, 20);
        expect(r.deflate(2), const Rect(2, 2, 16, 16));
      });

      test('deflate by 1', () {
        const r = Rect(5, 5, 10, 10);
        expect(r.deflate(1), const Rect(6, 6, 8, 8));
      });

      test('large deflation produces zero-size rect', () {
        const r = Rect(0, 0, 4, 4);
        final result = r.deflate(3);
        expect(result.width, 0);
        expect(result.height, 0);
      });
    });

    group('equality and hashCode', () {
      test('equal rects', () {
        const a = Rect(1, 2, 3, 4);
        const b = Rect(1, 2, 3, 4);
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('different rects', () {
        const a = Rect(1, 2, 3, 4);
        const b = Rect(1, 2, 3, 5);
        expect(a, isNot(b));
      });
    });

    test('toString', () {
      expect(const Rect(1, 2, 3, 4).toString(), 'Rect(1, 2, 3, 4)');
    });
  });
}
