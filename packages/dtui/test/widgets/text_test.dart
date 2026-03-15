import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('Text', () {
    late Buffer buffer;
    late Canvas canvas;
    const area = Rect(0, 0, 20, 5);

    setUp(() {
      buffer = Buffer(20, 5);
      canvas = Canvas(buffer, area);
    });

    test('renders string at top-left of area', () {
      final widget = Text('Hello');
      widget.render(canvas, area);
      expect(buffer.getCell(0, 0).char, 'H');
      expect(buffer.getCell(1, 0).char, 'e');
      expect(buffer.getCell(4, 0).char, 'o');
    });

    test('style applied to all characters', () {
      const style = Style(bold: true);
      final widget = Text('Hi', style: style);
      widget.render(canvas, area);
      expect(buffer.getCell(0, 0).style, style);
      expect(buffer.getCell(1, 0).style, style);
    });

    test('wraps when text exceeds area width', () {
      final smallArea = const Rect(0, 0, 5, 3);
      final widget = Text('HelloWorld');
      widget.render(canvas, smallArea);
      // First line: Hello
      expect(buffer.getCell(0, 0).char, 'H');
      expect(buffer.getCell(4, 0).char, 'o');
      // Second line: World
      expect(buffer.getCell(0, 1).char, 'W');
      expect(buffer.getCell(4, 1).char, 'd');
    });

    test('measure returns text length and 1 line', () {
      final widget = Text('Hello');
      final (w, h) = widget.measure(const BoxConstraints());
      expect(w, 5);
      expect(h, 1);
    });

    test('measure handles multi-line text', () {
      final widget = Text('Hi\nWorld');
      final (w, h) = widget.measure(const BoxConstraints());
      expect(w, 5); // "World" is the longest line
      expect(h, 2);
    });

    test('newline handling in render', () {
      final widget = Text('AB\nCD');
      widget.render(canvas, area);
      expect(buffer.getCell(0, 0).char, 'A');
      expect(buffer.getCell(1, 0).char, 'B');
      expect(buffer.getCell(0, 1).char, 'C');
      expect(buffer.getCell(1, 1).char, 'D');
    });

    test('empty area does not crash', () {
      final widget = Text('Hello');
      widget.render(canvas, const Rect(0, 0, 0, 0));
      // No exception
    });
  });

  group('RichText', () {
    late Buffer buffer;
    late Canvas canvas;
    const area = Rect(0, 0, 20, 5);

    setUp(() {
      buffer = Buffer(20, 5);
      canvas = Canvas(buffer, area);
    });

    test('renders multiple spans sequentially with correct styles', () {
      const style1 = Style(bold: true);
      const style2 = Style(italic: true);
      final widget = RichText([
        const TextSpan('He', style: style1),
        const TextSpan('lo', style: style2),
      ]);
      widget.render(canvas, area);
      expect(buffer.getCell(0, 0).char, 'H');
      expect(buffer.getCell(0, 0).style, style1);
      expect(buffer.getCell(1, 0).char, 'e');
      expect(buffer.getCell(1, 0).style, style1);
      expect(buffer.getCell(2, 0).char, 'l');
      expect(buffer.getCell(2, 0).style, style2);
      expect(buffer.getCell(3, 0).char, 'o');
      expect(buffer.getCell(3, 0).style, style2);
    });

    test('newline in span advances to next line', () {
      final widget = RichText([
        const TextSpan('A\nB'),
      ]);
      widget.render(canvas, area);
      expect(buffer.getCell(0, 0).char, 'A');
      expect(buffer.getCell(0, 1).char, 'B');
    });
  });
}
