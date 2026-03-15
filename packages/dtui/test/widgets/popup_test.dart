import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('Popup', () {
    late Buffer buffer;
    late Canvas canvas;
    const area = Rect(0, 0, 80, 24);

    setUp(() {
      buffer = Buffer(80, 24);
      canvas = Canvas(buffer, area);
    });

    test('centered in area', () {
      final popup = Popup(
        title: 'Test',
        child: Text(''),
        width: 20,
        height: 10,
      );
      popup.render(canvas, area);
      // Expected position: (80-20)/2=30, (24-10)/2=7
      // Top-left corner should be at (30, 7)
      expect(buffer.getCell(30, 7).char, isNot(' ')); // topLeft corner
      expect(buffer.getCell(49, 7).char, isNot(' ')); // topRight corner
    });

    test('clamps dimensions to screen size', () {
      final popup = Popup(
        title: 'Big',
        child: Text(''),
        width: 200,
        height: 100,
      );
      popup.render(canvas, area);
      // Should clamp to 80x24, centered at (0,0)
      expect(buffer.getCell(0, 0).char, isNot(' '));
    });

    test('visible toggle controls rendering', () {
      final popup = Popup(
        title: 'Test',
        child: Text('X'),
        width: 20,
        height: 10,
        visible: false,
      );
      popup.render(canvas, area);
      // Nothing should be rendered - buffer should be all empty
      for (var y = 0; y < 24; y++) {
        for (var x = 0; x < 80; x++) {
          expect(buffer.getCell(x, y), Cell.empty);
        }
      }
    });

    test('escape key calls onClose', () {
      var closed = false;
      final popup = Popup(
        title: 'Test',
        child: Text(''),
        onClose: () => closed = true,
      );
      final result = popup.handleEvent(const KeyEvent(keyEscape));
      expect(result, true);
      expect(closed, true);
      expect(popup.visible, false);
    });

    test('events delegated to child when visible', () {
      final list = ListView(items: [
        const ListItem(label: 'a'),
        const ListItem(label: 'b'),
      ]);
      final popup = Popup(title: 'Test', child: list);
      popup.handleEvent(const KeyEvent('j'));
      expect(list.selectedIndex, 1);
    });

    test('events not handled when not visible', () {
      final list = ListView(items: [
        const ListItem(label: 'a'),
        const ListItem(label: 'b'),
      ]);
      final popup = Popup(title: 'Test', child: list, visible: false);
      final result = popup.handleEvent(const KeyEvent('j'));
      expect(result, false);
      expect(list.selectedIndex, 0);
    });

    test('border and title rendered', () {
      final popup = Popup(
        title: 'My Popup',
        child: Text(''),
        width: 20,
        height: 10,
      );
      popup.render(canvas, area);
      // Title should appear at px+2
      final px = (80 - 20) ~/ 2;
      final py = (24 - 10) ~/ 2;
      expect(buffer.getCell(px + 2, py).char, 'M');
      expect(buffer.getCell(px + 3, py).char, 'y');
    });

    test('measure returns configured width and height', () {
      final popup = Popup(
        title: 'Test',
        child: Text(''),
        width: 40,
        height: 15,
      );
      final (w, h) = popup.measure(const BoxConstraints());
      expect(w, 40);
      expect(h, 15);
    });
  });
}
