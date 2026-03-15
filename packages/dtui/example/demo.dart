import 'package:dtui/dtui.dart';

/// A demo app showcasing every dtui widget.
///
/// Run with: dart run packages/dtui/example/demo.dart
///
/// Controls:
///   Tab        — cycle focus (list → input → list)
///   j/k ↑/↓   — navigate the list
///   p          — toggle popup
///   Escape     — close popup
///   q          — quit
void main() async {
  // ── Mutable state ──
  var focusedPane = 0; // 0 = left, 1 = right
  var selectedIndex = 0;
  var showPopup = false;
  var inputText = '';

  final items = [
    'Text',
    'RichText',
    'Border',
    'ListView',
    'Scrollbar',
    'SplitPane',
    'TextInput',
    'Popup',
  ];

  final descriptions = [
    'Renders a plain string with word wrapping.',
    'Renders multiple styled spans inline.',
    'Draws a rounded border with an optional title.',
    'Scrollable, selectable list with keyboard navigation.',
    'Vertical scrollbar track with proportional thumb.',
    'Splits area horizontally or vertically among children.',
    'Single-line editable text field with cursor.',
    'Centered overlay with border, title, and child widget.',
  ];

  late final TuiApp app;

  app = TuiApp(
    buildRoot: () {
      // ── Left pane: bordered list with scrollbar ──
      final listView = ListView(
        items: [
          for (var i = 0; i < items.length; i++)
            ListItem(
              label: '  ${items[i]}',
              style: Style(
                foreground: [
                  Color.cyan,
                  Color.green,
                  Color.yellow,
                  Color.magenta,
                  Color.blue,
                ][i % 5],
              ),
            ),
        ],
        selectedIndex: selectedIndex,
        selectedStyle: const Style(inverse: true, bold: true),
      );

      final scrollbar = Scrollbar(
        totalItems: items.length,
        visibleItems: 8,
        scrollOffset: listView.scrollOffset,
        trackStyle: const Style(dim: true),
        thumbStyle: const Style(foreground: Color.cyan),
      );

      final listWithScrollbar = SplitPane(
        direction: SplitDirection.horizontal,
        specs: [SplitSpec.flex(1), SplitSpec.fixed(1)],
        children: [listView, scrollbar],
        focusedIndex: 0,
      );

      final leftPane = Border(
        child: listWithScrollbar,
        title: 'Widgets',
        focused: focusedPane == 0,
        titleStyle: const Style(bold: true, foreground: Color.cyan),
      );

      // ── Right pane: detail area with Text, RichText, and TextInput ──
      final heading = Text(
        items[selectedIndex],
        style: const Style(bold: true, foreground: Color.yellow),
      );

      final description = RichText([
        const TextSpan('Widget: ', style: Style(bold: true)),
        TextSpan(
          items[selectedIndex],
          style: const Style(foreground: Color.green),
        ),
        const TextSpan('\n'),
        TextSpan(descriptions[selectedIndex]),
      ]);

      final textInput = TextInput(
        text: inputText,
        prompt: 'Search: ',
        textStyle: const Style(foreground: Color.white),
        cursorStyle: const Style(inverse: true, foreground: Color.cyan),
      );

      final detailContent = _DetailColumn(
        heading: heading,
        description: description,
        textInput: textInput,
        selectedIndex: selectedIndex,
        total: items.length,
        focusedPane: focusedPane,
      );

      final rightPane = Border(
        child: detailContent,
        title: 'Details',
        focused: focusedPane == 1,
        titleStyle: const Style(bold: true, foreground: Color.green),
      );

      // ── Root split ──
      Widget root = SplitPane(
        direction: SplitDirection.horizontal,
        specs: [SplitSpec.flex(0.35), SplitSpec.flex(0.65)],
        children: [leftPane, rightPane],
        focusedIndex: focusedPane,
      );

      // ── Popup overlay ──
      if (showPopup) {
        root = _PopupOverlay(background: root, showPopup: showPopup);
      }

      return root;
    },
    onEvent: (event) {
      if (event is! KeyEvent) return;

      // Popup consumes Escape
      if (showPopup && event.key == keyEscape) {
        showPopup = false;
        return;
      }

      switch (event.key) {
        case 'q':
          app.exit();
        case keyTab:
          focusedPane = (focusedPane + 1) % 2;
        case keyDown:
        case 'j':
          if (focusedPane == 0 && selectedIndex < items.length - 1) {
            selectedIndex++;
          }
        case keyUp:
        case 'k':
          if (focusedPane == 0 && selectedIndex > 0) selectedIndex--;
        case 'g':
          if (focusedPane == 0) selectedIndex = 0;
        case 'G':
          if (focusedPane == 0) selectedIndex = items.length - 1;
        case 'p':
          showPopup = !showPopup;
        case keyBackspace:
          if (focusedPane == 1 && inputText.isNotEmpty) {
            inputText = inputText.substring(0, inputText.length - 1);
          }
        default:
          // Typing into the text input when right pane is focused
          if (focusedPane == 1 &&
              !event.ctrl &&
              !event.alt &&
              !showPopup) {
            String? ch;
            if (event.key == keySpace) {
              ch = ' ';
            } else if (event.key.length == 1) {
              ch = event.key;
            }
            if (ch != null) inputText += ch;
          }
      }
    },
  );

  await app.run();
}

/// Lays out the right-pane detail content vertically.
class _DetailColumn extends Widget {
  final Text heading;
  final RichText description;
  final TextInput textInput;
  final int selectedIndex;
  final int total;
  final int focusedPane;

  _DetailColumn({
    required this.heading,
    required this.description,
    required this.textInput,
    required this.selectedIndex,
    required this.total,
    required this.focusedPane,
  });

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0) return;

    var y = area.top;

    // Heading
    heading.render(canvas, Rect(area.left, y, area.width, 1));
    y += 2;

    // RichText description
    if (y + 2 < area.bottom) {
      description.render(canvas, Rect(area.left, y, area.width, 2));
      y += 3;
    }

    // Progress bar
    if (y < area.bottom && area.width >= 4) {
      final barWidth = (area.width - 2).clamp(0, 30);
      final filled = ((selectedIndex + 1) / total * barWidth).round();
      final bar = '\u2588' * filled + '\u2591' * (barWidth - filled);
      _drawLine(
          canvas, area.left, y, bar, const Style(foreground: Color.cyan));
      y += 1;
      _drawLine(canvas, area.left, y, '${selectedIndex + 1} / $total',
          const Style(dim: true));
      y += 2;
    }

    // TextInput
    if (y < area.bottom) {
      final inputArea = Rect(area.left, y, area.width, 1);
      if (focusedPane == 1) {
        _drawLine(canvas, area.left, y, '', Style.none); // clear line
      }
      textInput.render(canvas, inputArea);
      y += 2;
    }

    // Keybinding hints
    if (y < area.bottom) {
      _drawLine(canvas, area.left, y,
          'j/k navigate  Tab focus  p popup  q quit', const Style(dim: true));
    }
  }

  void _drawLine(Canvas canvas, int x, int y, String text, Style style) {
    for (var i = 0; i < text.length; i++) {
      canvas.drawChar(x + i, y, text[i], style);
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(constraints.maxWidth, constraints.maxHeight);
  }
}

/// Renders the background widget, then overlays a [Popup] on top.
class _PopupOverlay extends Widget {
  final Widget background;
  final bool showPopup;

  _PopupOverlay({required this.background, required this.showPopup});

  @override
  List<Widget> get children => [background];

  @override
  void render(Canvas canvas, Rect area) {
    // Draw background first
    background.render(canvas, area);

    // Draw popup on top
    if (showPopup) {
      final popupContent = RichText([
        const TextSpan('This is a Popup widget!\n\n',
            style: Style(bold: true, foreground: Color.yellow)),
        const TextSpan('It renders centered over\n'),
        const TextSpan('the rest of the UI.\n\n'),
        const TextSpan('Press ',
            style: Style(dim: true)),
        const TextSpan('Escape',
            style: Style(bold: true, foreground: Color.cyan)),
        const TextSpan(' to close.',
            style: Style(dim: true)),
      ]);

      final popup = Popup(
        title: 'Demo Popup',
        child: popupContent,
        width: 36,
        height: 10,
        borderStyle: const Style(foreground: Color.magenta),
        titleStyle: const Style(bold: true, foreground: Color.magenta),
        visible: true,
      );

      popup.render(canvas, area);
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return background.measure(constraints);
  }
}
