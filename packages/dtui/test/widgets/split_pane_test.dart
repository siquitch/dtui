import 'package:dtui/dtui.dart';
import 'package:test/test.dart';

void main() {
  group('SplitPane', () {
    late Buffer buffer;
    late Canvas canvas;
    const area = Rect(0, 0, 20, 10);

    setUp(() {
      buffer = Buffer(20, 10);
      canvas = Canvas(buffer, area);
    });

    test('renders children in split areas (horizontal)', () {
      final left = Text('L');
      final right = Text('R');
      final pane = SplitPane(
        direction: SplitDirection.horizontal,
        children: [left, right],
        specs: [const SplitSpec.flex(1), const SplitSpec.flex(1)],
      );
      pane.render(canvas, area);
      expect(buffer.getCell(0, 0).char, 'L');
      expect(buffer.getCell(10, 0).char, 'R');
    });

    test('renders children in split areas (vertical)', () {
      final top = Text('T');
      final bottom = Text('B');
      final pane = SplitPane(
        direction: SplitDirection.vertical,
        children: [top, bottom],
        specs: [const SplitSpec.flex(1), const SplitSpec.flex(1)],
      );
      pane.render(canvas, area);
      expect(buffer.getCell(0, 0).char, 'T');
      expect(buffer.getCell(0, 5).char, 'B');
    });

    test('focusedIndex determines which child receives events', () {
      var leftHandled = false;
      var rightHandled = false;

      final leftList = ListView(
        items: [const ListItem(label: 'a'), const ListItem(label: 'b')],
        onSelect: (_) => leftHandled = true,
      );
      final rightList = ListView(
        items: [const ListItem(label: 'c'), const ListItem(label: 'd')],
        onSelect: (_) => rightHandled = true,
      );

      final pane = SplitPane(
        direction: SplitDirection.horizontal,
        children: [leftList, rightList],
        specs: [const SplitSpec.flex(1), const SplitSpec.flex(1)],
        focusedIndex: 0,
      );

      pane.handleEvent(const KeyEvent('j'));
      expect(leftHandled, true);
      expect(rightHandled, false);

      leftHandled = false;
      pane.focusedIndex = 1;
      pane.handleEvent(const KeyEvent('j'));
      expect(leftHandled, false);
      expect(rightHandled, true);
    });

    test('empty children list handled', () {
      final pane = SplitPane(
        direction: SplitDirection.horizontal,
        children: [],
        specs: [],
      );
      pane.render(canvas, area);
      expect(pane.handleEvent(const KeyEvent('j')), false);
    });
  });
}
