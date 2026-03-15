import '../layout/constraint.dart';
import '../layout/rect.dart';
import '../rendering/canvas.dart';
import '../style/style.dart';
import '../terminal/input_parser.dart';
import 'widget.dart';

/// An item in a [ListView].
class ListItem {
  final String label;
  final Style? style;
  final dynamic data;

  const ListItem({required this.label, this.style, this.data});
}

/// A scrollable, selectable list widget.
class ListView extends Widget {
  final List<ListItem> items;
  int _selectedIndex;
  int _scrollOffset;
  final void Function(int index)? onSelect;

  /// Style for the selected item highlight.
  final Style selectedStyle;

  ListView({
    required this.items,
    int selectedIndex = 0,
    this.onSelect,
    this.selectedStyle = const Style(inverse: true),
  })  : _selectedIndex = items.isEmpty ? -1 : selectedIndex.clamp(0, items.length - 1),
        _scrollOffset = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    if (items.isEmpty) return;
    _selectedIndex = value.clamp(0, items.length - 1);
  }

  int get scrollOffset => _scrollOffset;

  ListItem? get selectedItem =>
      _selectedIndex >= 0 && _selectedIndex < items.length
          ? items[_selectedIndex]
          : null;

  void selectNext() {
    if (items.isEmpty) return;
    _selectedIndex = (_selectedIndex + 1).clamp(0, items.length - 1);
  }

  void selectPrevious() {
    if (items.isEmpty) return;
    _selectedIndex = (_selectedIndex - 1).clamp(0, items.length - 1);
  }

  void selectFirst() {
    if (items.isEmpty) return;
    _selectedIndex = 0;
  }

  void selectLast() {
    if (items.isEmpty) return;
    _selectedIndex = items.length - 1;
  }

  void pageDown(int pageSize) {
    if (items.isEmpty) return;
    _selectedIndex = (_selectedIndex + pageSize).clamp(0, items.length - 1);
  }

  void pageUp(int pageSize) {
    if (items.isEmpty) return;
    _selectedIndex = (_selectedIndex - pageSize).clamp(0, items.length - 1);
  }

  void _ensureVisible(int visibleHeight) {
    if (items.isEmpty || visibleHeight <= 0) return;
    if (_selectedIndex < _scrollOffset) {
      _scrollOffset = _selectedIndex;
    } else if (_selectedIndex >= _scrollOffset + visibleHeight) {
      _scrollOffset = _selectedIndex - visibleHeight + 1;
    }
  }

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0 || items.isEmpty) return;

    _ensureVisible(area.height);

    final visibleCount = area.height;
    for (var i = 0; i < visibleCount; i++) {
      final itemIndex = _scrollOffset + i;
      if (itemIndex >= items.length) break;

      final item = items[itemIndex];
      final y = area.top + i;
      final isSelected = itemIndex == _selectedIndex;

      // Determine style
      Style style;
      if (isSelected) {
        style = selectedStyle;
        if (item.style != null) {
          style = item.style!.merge(selectedStyle);
        }
      } else {
        style = item.style ?? Style.none;
      }

      // Clear the line first
      for (var x = area.left; x < area.right; x++) {
        canvas.drawChar(x, y, ' ', style);
      }

      // Draw the label, truncated to fit
      final label = item.label;
      final maxLen = area.width;
      final displayLen = label.length > maxLen ? maxLen : label.length;
      for (var j = 0; j < displayLen; j++) {
        canvas.drawChar(area.left + j, y, label[j], style);
      }
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    var maxWidth = 0;
    for (final item in items) {
      if (item.label.length > maxWidth) maxWidth = item.label.length;
    }
    return constraints.constrain(maxWidth, items.length);
  }

  @override
  bool handleEvent(InputEvent event) {
    if (event is! KeyEvent) return false;
    if (items.isEmpty) return false;

    switch (event.key) {
      case keyDown:
      case 'j':
        selectNext();
        onSelect?.call(_selectedIndex);
        return true;
      case keyUp:
      case 'k':
        selectPrevious();
        onSelect?.call(_selectedIndex);
        return true;
      case 'g':
        selectFirst();
        onSelect?.call(_selectedIndex);
        return true;
      case 'G':
        selectLast();
        onSelect?.call(_selectedIndex);
        return true;
      case keyPageDown:
        pageDown(10);
        onSelect?.call(_selectedIndex);
        return true;
      case keyPageUp:
        pageUp(10);
        onSelect?.call(_selectedIndex);
        return true;
      case keyHome:
        selectFirst();
        onSelect?.call(_selectedIndex);
        return true;
      case keyEnd:
        selectLast();
        onSelect?.call(_selectedIndex);
        return true;
      default:
        return false;
    }
  }
}
