import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('ListView', () {
    late Buffer buffer;
    late Canvas canvas;
    const area = Rect(0, 0, 20, 5);

    setUp(() {
      buffer = Buffer(20, 5);
      canvas = Canvas(buffer, area);
    });

    List<ListItem> makeItems(int count) =>
        List.generate(count, (i) => ListItem(label: 'Item $i'));

    test('renders items within area', () {
      final lv = ListView(items: makeItems(3));
      lv.render(canvas, area);
      expect(buffer.getCell(0, 0).char, 'I');
      expect(buffer.getCell(0, 1).char, 'I');
      expect(buffer.getCell(0, 2).char, 'I');
    });

    test('selectedIndex highlights with selectedStyle', () {
      const selStyle = Style(inverse: true);
      final lv = ListView(
        items: makeItems(3),
        selectedIndex: 1,
        selectedStyle: selStyle,
      );
      lv.render(canvas, area);
      // Row 0 (not selected) should be Style.none
      expect(buffer.getCell(0, 0).style, Style.none);
      // Row 1 (selected) should have inverse style
      expect(buffer.getCell(0, 1).style, selStyle);
    });

    group('navigation', () {
      test('selectNext clamps to bounds', () {
        final lv = ListView(items: makeItems(3), selectedIndex: 1);
        lv.selectNext();
        expect(lv.selectedIndex, 2);
        lv.selectNext();
        expect(lv.selectedIndex, 2); // clamped
      });

      test('selectPrevious clamps to 0', () {
        final lv = ListView(items: makeItems(3), selectedIndex: 1);
        lv.selectPrevious();
        expect(lv.selectedIndex, 0);
        lv.selectPrevious();
        expect(lv.selectedIndex, 0); // clamped
      });

      test('selectFirst and selectLast', () {
        final lv = ListView(items: makeItems(5), selectedIndex: 2);
        lv.selectFirst();
        expect(lv.selectedIndex, 0);
        lv.selectLast();
        expect(lv.selectedIndex, 4);
      });

      test('pageDown and pageUp', () {
        final lv = ListView(items: makeItems(20), selectedIndex: 5);
        lv.pageDown(10);
        expect(lv.selectedIndex, 15);
        lv.pageUp(10);
        expect(lv.selectedIndex, 5);
      });

      test('pageDown clamps to end', () {
        final lv = ListView(items: makeItems(5), selectedIndex: 3);
        lv.pageDown(10);
        expect(lv.selectedIndex, 4);
      });
    });

    group('scroll offset', () {
      test('adjusts to keep selection visible', () {
        final lv = ListView(items: makeItems(20), selectedIndex: 0);
        // Area height is 5, so items 0-4 visible
        lv.render(canvas, area);
        expect(lv.scrollOffset, 0);

        // Move to item 6 (beyond visible)
        lv.selectedIndex = 6;
        lv.render(canvas, area);
        expect(lv.scrollOffset, 2); // 6 - 5 + 1 = 2
      });
    });

    group('handleEvent', () {
      test('j/Down moves down', () {
        final lv = ListView(items: makeItems(5));
        expect(lv.handleEvent(const KeyEvent('j')), true);
        expect(lv.selectedIndex, 1);
        expect(lv.handleEvent(const KeyEvent(keyDown)), true);
        expect(lv.selectedIndex, 2);
      });

      test('k/Up moves up', () {
        final lv = ListView(items: makeItems(5), selectedIndex: 2);
        expect(lv.handleEvent(const KeyEvent('k')), true);
        expect(lv.selectedIndex, 1);
        expect(lv.handleEvent(const KeyEvent(keyUp)), true);
        expect(lv.selectedIndex, 0);
      });

      test('g goes to first, G goes to last', () {
        final lv = ListView(items: makeItems(5), selectedIndex: 2);
        lv.handleEvent(const KeyEvent('g'));
        expect(lv.selectedIndex, 0);
        lv.handleEvent(const KeyEvent('G'));
        expect(lv.selectedIndex, 4);
      });

      test('PageDown/PageUp', () {
        final lv = ListView(items: makeItems(30), selectedIndex: 0);
        lv.handleEvent(const KeyEvent(keyPageDown));
        expect(lv.selectedIndex, 10);
        lv.handleEvent(const KeyEvent(keyPageUp));
        expect(lv.selectedIndex, 0);
      });

      test('Home/End', () {
        final lv = ListView(items: makeItems(10), selectedIndex: 5);
        lv.handleEvent(const KeyEvent(keyHome));
        expect(lv.selectedIndex, 0);
        lv.handleEvent(const KeyEvent(keyEnd));
        expect(lv.selectedIndex, 9);
      });

      test('unhandled key returns false', () {
        final lv = ListView(items: makeItems(5));
        expect(lv.handleEvent(const KeyEvent('x')), false);
      });

      test('onSelect callback called on navigation', () {
        int? selectedIdx;
        final lv = ListView(
          items: makeItems(5),
          onSelect: (idx) => selectedIdx = idx,
        );
        lv.handleEvent(const KeyEvent('j'));
        expect(selectedIdx, 1);
      });
    });

    group('empty items', () {
      test('handles gracefully', () {
        final lv = ListView(items: []);
        expect(lv.selectedIndex, -1);
        lv.render(canvas, area);
        lv.selectNext();
        expect(lv.selectedIndex, -1);
        expect(lv.handleEvent(const KeyEvent('j')), false);
      });
    });

    test('measure returns max label width and item count', () {
      final lv = ListView(items: [
        const ListItem(label: 'Short'),
        const ListItem(label: 'A longer label'),
      ]);
      final (w, h) = lv.measure(const BoxConstraints());
      expect(w, 14);
      expect(h, 2);
    });
  });
}
