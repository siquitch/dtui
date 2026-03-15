import 'package:dtui/dtui.dart';

import '../../git/models/git_diff.dart';
import 'context.dart';

class DiffViewContext extends Context {
  GitDiff? diff;
  int scrollOffset = 0;
  int selectedLine = 0;

  @override
  String get name => 'diff';

  int get _totalLines {
    if (diff == null) return 0;
    var count = 0;
    for (final hunk in diff!.hunks) {
      count += 1 + hunk.lines.length; // header + lines
    }
    return count;
  }

  void nextHunk() {
    if (diff == null || diff!.hunks.isEmpty) return;
    var lineIndex = 0;
    for (final hunk in diff!.hunks) {
      if (lineIndex > selectedLine) {
        selectedLine = lineIndex;
        return;
      }
      lineIndex += 1 + hunk.lines.length;
    }
  }

  void previousHunk() {
    if (diff == null || diff!.hunks.isEmpty) return;
    var lastHunkStart = 0;
    var lineIndex = 0;
    for (final hunk in diff!.hunks) {
      if (lineIndex >= selectedLine) break;
      lastHunkStart = lineIndex;
      lineIndex += 1 + hunk.lines.length;
    }
    if (lastHunkStart < selectedLine) {
      selectedLine = lastHunkStart;
    }
  }

  @override
  bool handleEvent(InputEvent event) {
    if (event is! KeyEvent) return false;
    final total = _totalLines;
    switch (event.key) {
      case keyDown:
      case 'j':
        if (selectedLine < total - 1) selectedLine++;
        return true;
      case keyUp:
      case 'k':
        if (selectedLine > 0) selectedLine--;
        return true;
      case ']':
        nextHunk();
        return true;
      case '[':
        previousHunk();
        return true;
      case keyPageDown:
        selectedLine = (selectedLine + 20).clamp(0, total - 1);
        return true;
      case keyPageUp:
        selectedLine = (selectedLine - 20).clamp(0, total - 1);
        return true;
      default:
        return false;
    }
  }
}
