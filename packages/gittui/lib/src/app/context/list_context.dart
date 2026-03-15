import 'package:dtui/dtui.dart';

import 'context.dart';

abstract class ListContext extends Context {
  int selectedIndex = 0;
  int scrollOffset = 0;

  int get itemCount;

  void selectNext() {
    if (itemCount == 0) return;
    selectedIndex = (selectedIndex + 1).clamp(0, itemCount - 1);
  }

  void selectPrevious() {
    if (itemCount == 0) return;
    selectedIndex = (selectedIndex - 1).clamp(0, itemCount - 1);
  }

  void selectFirst() {
    selectedIndex = 0;
  }

  void selectLast() {
    if (itemCount == 0) return;
    selectedIndex = itemCount - 1;
  }

  void pageDown(int pageSize) {
    if (itemCount == 0) return;
    selectedIndex = (selectedIndex + pageSize).clamp(0, itemCount - 1);
  }

  void pageUp(int pageSize) {
    if (itemCount == 0) return;
    selectedIndex = (selectedIndex - pageSize).clamp(0, itemCount - 1);
  }

  void ensureVisible(int viewportHeight) {
    if (itemCount == 0 || viewportHeight <= 0) return;
    if (selectedIndex < scrollOffset) {
      scrollOffset = selectedIndex;
    } else if (selectedIndex >= scrollOffset + viewportHeight) {
      scrollOffset = selectedIndex - viewportHeight + 1;
    }
  }

  @override
  bool handleEvent(InputEvent event) {
    if (event is! KeyEvent) return false;
    switch (event.key) {
      case keyDown:
      case 'j':
        selectNext();
        return true;
      case keyUp:
      case 'k':
        selectPrevious();
        return true;
      case 'g':
        selectFirst();
        return true;
      case 'G':
        selectLast();
        return true;
      case keyPageDown:
        pageDown(10);
        return true;
      case keyPageUp:
        pageUp(10);
        return true;
      default:
        return false;
    }
  }
}
