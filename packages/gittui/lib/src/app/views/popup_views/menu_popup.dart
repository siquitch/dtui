import 'package:dtui/dtui.dart';

class MenuItem {
  final String label;
  final String? key;
  final void Function() action;

  const MenuItem({required this.label, this.key, required this.action});
}

class MenuPopup extends Widget {
  final String title;
  final List<MenuItem> items;
  final void Function()? onCancel;
  int _selectedIndex = 0;

  MenuPopup({
    required this.title,
    required this.items,
    this.onCancel,
  });

  @override
  void render(Canvas canvas, Rect area) {
    final content = _MenuContent(
      items: items,
      selectedIndex: _selectedIndex,
    );
    final popup = Popup(
      title: title,
      child: content,
      width: (area.width * 0.4).toInt().clamp(20, 50),
      height: (items.length + 2).clamp(4, area.height - 4),
      onClose: onCancel,
    );
    popup.render(canvas, area);
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(40, items.length + 4);
  }

  @override
  bool handleEvent(InputEvent event) {
    if (event is! KeyEvent) return false;
    switch (event.key) {
      case keyDown:
      case 'j':
        _selectedIndex = (_selectedIndex + 1).clamp(0, items.length - 1);
        return true;
      case keyUp:
      case 'k':
        _selectedIndex = (_selectedIndex - 1).clamp(0, items.length - 1);
        return true;
      case keyEnter:
        if (items.isNotEmpty) {
          items[_selectedIndex].action();
        }
        return true;
      case keyEscape:
        onCancel?.call();
        return true;
      default:
        // Check shortcut keys
        for (final item in items) {
          if (item.key != null && item.key == event.key) {
            item.action();
            return true;
          }
        }
        return false;
    }
  }
}

class _MenuContent extends Widget {
  final List<MenuItem> items;
  final int selectedIndex;

  _MenuContent({required this.items, required this.selectedIndex});

  @override
  void render(Canvas canvas, Rect area) {
    for (var i = 0; i < items.length && i < area.height; i++) {
      final item = items[i];
      final isSelected = i == selectedIndex;
      final style = isSelected ? const Style(inverse: true) : Style.none;

      // Clear line
      for (var x = area.x; x < area.right; x++) {
        canvas.drawChar(x, area.y + i, ' ', isSelected ? style : Style.none);
      }

      var label = item.label;
      if (item.key != null) {
        label = '[${item.key}] $label';
      }
      for (var j = 0; j < label.length && j < area.width; j++) {
        canvas.drawChar(area.x + j, area.y + i, label[j], style);
      }
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(constraints.maxWidth, items.length);
  }

  @override
  bool handleEvent(InputEvent event) => false;
}
