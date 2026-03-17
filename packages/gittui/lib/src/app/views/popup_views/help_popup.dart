import 'package:dtui/dtui.dart';

import '../../keybindings/keybinding.dart';

class HelpPopup extends Widget {
  final List<Keybinding> bindings;
  final void Function() onClose;
  int _scrollOffset = 0;

  HelpPopup({
    required this.bindings,
    required this.onClose,
  });

  @override
  void render(Canvas canvas, Rect area) {
    final popWidth = (area.width * 0.6).toInt().clamp(30, 70);
    final popHeight = (area.height * 0.7).toInt().clamp(10, area.height - 4);

    final content = _HelpContent(
      bindings: bindings,
      scrollOffset: _scrollOffset,
    );
    final popup = Popup(
      title: 'Keybindings',
      child: content,
      width: popWidth,
      height: popHeight,
      onClose: onClose,
    );
    popup.render(canvas, area);
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(60, 20);
  }

  @override
  bool handleEvent(InputEvent event) {
    if (event is! KeyEvent) return false;
    switch (event.key) {
      case keyEscape:
      case 'q':
      case '?':
        onClose();
        return true;
      case keyDown:
      case 'j':
        _scrollOffset++;
        return true;
      case keyUp:
      case 'k':
        if (_scrollOffset > 0) _scrollOffset--;
        return true;
      case keyPageDown:
        _scrollOffset += 10;
        return true;
      case keyPageUp:
        _scrollOffset = (_scrollOffset - 10).clamp(0, _scrollOffset);
        return true;
      case 'g':
        _scrollOffset = 0;
        return true;
      case 'G':
        _scrollOffset = _totalLines - 1;
        return true;
      default:
        return false;
    }
  }

  int get _totalLines => _buildLines(bindings).length;

  static List<_HelpLine> _buildLines(List<Keybinding> bindings) {
    final lines = <_HelpLine>[];

    // Group by context
    final global = bindings.where((b) => b.context == null).toList();
    final contexts = <String, List<Keybinding>>{};
    for (final b in bindings) {
      if (b.context != null) {
        contexts.putIfAbsent(b.context!, () => []).add(b);
      }
    }

    lines.add(_HelpLine.header('Global'));
    for (final b in global) {
      lines.add(_HelpLine.binding(b.key, b.description));
    }

    for (final entry in contexts.entries) {
      lines.add(_HelpLine.empty());
      lines.add(
        _HelpLine.header(
          '${entry.key[0].toUpperCase()}${entry.key.substring(1)}',
        ),
      );
      for (final b in entry.value) {
        lines.add(_HelpLine.binding(b.key, b.description));
      }
    }

    // Navigation footer
    lines.add(_HelpLine.empty());
    lines.add(_HelpLine.header('Navigation'));
    lines.add(_HelpLine.binding('j/k', 'Scroll up/down'));
    lines.add(_HelpLine.binding('g/G', 'Top/bottom'));
    lines.add(_HelpLine.binding('Esc/?', 'Close'));

    return lines;
  }
}

enum _HelpLineType { header, binding, empty }

class _HelpLine {
  final _HelpLineType type;
  final String text;
  final String? description;

  _HelpLine.header(this.text) : type = _HelpLineType.header, description = null;
  _HelpLine.binding(this.text, this.description) : type = _HelpLineType.binding;
  _HelpLine.empty() : type = _HelpLineType.empty, text = '', description = null;
}

class _HelpContent extends Widget {
  final List<Keybinding> bindings;
  final int scrollOffset;

  _HelpContent({required this.bindings, required this.scrollOffset});

  @override
  void render(Canvas canvas, Rect area) {
    final lines = HelpPopup._buildLines(bindings);
    final keyColWidth = 14;

    final maxScroll = (lines.length - area.height).clamp(0, lines.length);
    final offset = scrollOffset.clamp(0, maxScroll);

    for (var i = 0; i < area.height && (i + offset) < lines.length; i++) {
      final line = lines[i + offset];
      final y = area.y + i;

      switch (line.type) {
        case _HelpLineType.header:
          final style = const Style(bold: true);
          for (var j = 0; j < line.text.length && j < area.width; j++) {
            canvas.drawChar(area.x + j, y, line.text[j], style);
          }
        case _HelpLineType.binding:
          // Key in dim style, description in normal
          final keyStyle = const Style(dim: true);
          final key = line.text.padRight(keyColWidth);
          for (var j = 0; j < key.length && j < area.width; j++) {
            canvas.drawChar(area.x + j, y, key[j], keyStyle);
          }
          final desc = line.description ?? '';
          for (
            var j = 0;
            j < desc.length && (j + keyColWidth) < area.width;
            j++
          ) {
            canvas.drawChar(area.x + keyColWidth + j, y, desc[j], Style.none);
          }
        case _HelpLineType.empty:
          break;
      }
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  bool handleEvent(InputEvent event) => false;
}
