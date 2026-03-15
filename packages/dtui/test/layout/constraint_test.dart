import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('BoxConstraints', () {
    group('default constructor', () {
      test('has unbounded max', () {
        const c = BoxConstraints();
        expect(c.minWidth, 0);
        expect(c.minHeight, 0);
        expect(c.maxWidth, 0x7FFFFFFF);
        expect(c.maxHeight, 0x7FFFFFFF);
      });
    });

    group('tight', () {
      test('min equals max', () {
        const c = BoxConstraints.tight(100, 50);
        expect(c.minWidth, 100);
        expect(c.maxWidth, 100);
        expect(c.minHeight, 50);
        expect(c.maxHeight, 50);
      });
    });

    group('loose', () {
      test('min is 0, max is specified', () {
        const c = BoxConstraints.loose(100, 50);
        expect(c.minWidth, 0);
        expect(c.maxWidth, 100);
        expect(c.minHeight, 0);
        expect(c.maxHeight, 50);
      });
    });

    group('getters', () {
      test('isTight', () {
        expect(const BoxConstraints.tight(10, 20).isTight, true);
        expect(const BoxConstraints.loose(10, 20).isTight, false);
        expect(const BoxConstraints().isTight, false);
      });

      test('hasBoundedWidth', () {
        expect(const BoxConstraints.tight(10, 20).hasBoundedWidth, true);
        expect(const BoxConstraints().hasBoundedWidth, false);
      });

      test('hasBoundedHeight', () {
        expect(const BoxConstraints.tight(10, 20).hasBoundedHeight, true);
        expect(const BoxConstraints().hasBoundedHeight, false);
      });
    });

    group('constrain', () {
      test('clamps values within bounds', () {
        const c = BoxConstraints(
          minWidth: 10,
          maxWidth: 100,
          minHeight: 5,
          maxHeight: 50,
        );
        expect(c.constrain(50, 25), (50, 25));
        expect(c.constrain(0, 0), (10, 5));
        expect(c.constrain(200, 200), (100, 50));
      });

      test('tight constraints always return exact size', () {
        const c = BoxConstraints.tight(42, 24);
        expect(c.constrain(0, 0), (42, 24));
        expect(c.constrain(100, 100), (42, 24));
      });
    });

    group('equality and hashCode', () {
      test('equal constraints', () {
        const a = BoxConstraints.tight(10, 20);
        const b = BoxConstraints.tight(10, 20);
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('different constraints', () {
        const a = BoxConstraints.tight(10, 20);
        const b = BoxConstraints.tight(10, 21);
        expect(a, isNot(b));
      });
    });
  });
}
