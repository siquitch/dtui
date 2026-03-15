import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('Border', () {
    late Buffer buffer;
    late Canvas canvas;
    const area = Rect(0, 0, 10, 5);

    setUp(() {
      buffer = Buffer(10, 5);
      canvas = Canvas(buffer, area);
    });

    test('draws box characters around child area', () {
      const chars = BoxChars.single();
      final border = Border(child: Text(''), chars: chars);
      border.render(canvas, area);
      expect(buffer.getCell(0, 0).char, chars.topLeft);
      expect(buffer.getCell(9, 0).char, chars.topRight);
      expect(buffer.getCell(0, 4).char, chars.bottomLeft);
      expect(buffer.getCell(9, 4).char, chars.bottomRight);
      // Horizontal edges
      expect(buffer.getCell(1, 0).char, chars.horizontal);
      expect(buffer.getCell(1, 4).char, chars.horizontal);
      // Vertical edges
      expect(buffer.getCell(0, 1).char, chars.vertical);
      expect(buffer.getCell(9, 1).char, chars.vertical);
    });

    test('title rendered at top within border', () {
      final border = Border(
        child: Text(''),
        title: 'Test',
        titleStyle: const Style(bold: true),
      );
      border.render(canvas, area);
      expect(buffer.getCell(2, 0).char, 'T');
      expect(buffer.getCell(3, 0).char, 'e');
      expect(buffer.getCell(4, 0).char, 's');
      expect(buffer.getCell(5, 0).char, 't');
      expect(buffer.getCell(2, 0).style, const Style(bold: true));
    });

    test('child rendered inside border (deflated by 1)', () {
      final border = Border(child: Text('Hi'));
      border.render(canvas, area);
      // Child area starts at (1,1)
      expect(buffer.getCell(1, 1).char, 'H');
      expect(buffer.getCell(2, 1).char, 'i');
    });

    test('different BoxChars styles', () {
      for (final chars in [
        const BoxChars.single(),
        const BoxChars.rounded(),
        const BoxChars.heavy(),
        const BoxChars.double_(),
      ]) {
        final buf = Buffer(10, 5);
        final c = Canvas(buf, area);
        final border = Border(child: Text(''), chars: chars);
        border.render(c, area);
        expect(buf.getCell(0, 0).char, chars.topLeft);
        expect(buf.getCell(9, 0).char, chars.topRight);
      }
    });

    test('focused flag switches border style', () {
      const normalStyle = Style.none;
      final border = Border(
        child: Text(''),
        borderStyle: normalStyle,
        focused: true,
      );
      border.render(canvas, area);
      // Focused defaults to bold
      expect(buffer.getCell(0, 0).style.bold, true);
    });

    test('unfocused uses normal border style', () {
      const normalStyle = Style(foreground: Color.red);
      final border = Border(
        child: Text(''),
        borderStyle: normalStyle,
        focused: false,
      );
      border.render(canvas, area);
      expect(buffer.getCell(0, 0).style, normalStyle);
    });

    test('events delegated to child', () {
      final list = ListView(items: [
        const ListItem(label: 'a'),
        const ListItem(label: 'b'),
      ]);
      final border = Border(child: list);
      expect(border.handleEvent(const KeyEvent('j')), true);
      expect(list.selectedIndex, 1);
    });

    test('too small area does not crash', () {
      final border = Border(child: Text('Hi'));
      border.render(canvas, const Rect(0, 0, 1, 1));
      // No exception
    });
  });
}
