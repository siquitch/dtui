import 'package:dtui/dtui.dart';

import '../../git/git_command_runner.dart';
import '../state/app_state.dart';
import 'command_log_view.dart';
import 'diff_view.dart';
import 'sidebar.dart';

class MainLayout extends Widget {
  final AppState appState;
  final int selectedFileIndex;
  final int selectedBranchIndex;
  final int selectedCommitIndex;
  final int diffScrollOffset;
  final int diffSelectedLine;
  final List<CommandLogEntry> commandLog;

  MainLayout({
    required this.appState,
    this.selectedFileIndex = 0,
    this.selectedBranchIndex = 0,
    this.selectedCommitIndex = 0,
    this.diffScrollOffset = 0,
    this.diffSelectedLine = 0,
    this.commandLog = const [],
  });

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0) return;

    // Reserve 1 row for status bar at bottom
    final mainHeight = area.height > 1 ? area.height - 1 : area.height;
    // Split sidebar | main content
    final sidebarWidth = (area.width * appState.ui.sidebarWidthPercent ~/ 100)
        .clamp(10, area.width - 10);
    final mainWidth = area.width - sidebarWidth - 1; // 1 for divider

    // Sidebar (3 stacked panes, each with its own border)
    final sidebarArea = Rect(area.x, area.y, sidebarWidth, mainHeight);
    final sidebar = Sidebar(
      appState: appState,
      selectedFileIndex: selectedFileIndex,
      selectedBranchIndex: selectedBranchIndex,
      selectedCommitIndex: selectedCommitIndex,
    );
    sidebar.render(canvas, sidebarArea);

    // Divider
    final dividerX = area.x + sidebarWidth;
    for (var y = area.y; y < area.y + mainHeight; y++) {
      canvas.drawChar(dividerX, y, '\u2502', const Style(dim: true));
    }

    // Right panel
    if (mainWidth > 0) {
      final rightArea = Rect(dividerX + 1, area.y, mainWidth, mainHeight);

      if (appState.ui.showCommandLog) {
        final cmdBorder = Border(
          child: CommandLogView(entries: commandLog),
          title: 'Command Log',
        );
        cmdBorder.render(canvas, rightArea);
      } else {
        final diffBorder = Border(
          child: DiffView(
            diff: appState.git.selectedDiff,
            scrollOffset: diffScrollOffset,
            selectedLine: diffSelectedLine,
          ),
          title: 'Diff',
        );
        diffBorder.render(canvas, rightArea);
      }
    }

    // Status bar
    if (area.height > 1) {
      _renderStatusBar(canvas, Rect(area.x, area.y + mainHeight, area.width, 1));
    }
  }

  void _renderStatusBar(Canvas canvas, Rect area) {
    final style = const Style(inverse: true);

    // Clear line
    for (var x = area.x; x < area.right; x++) {
      canvas.drawChar(x, area.y, ' ', style);
    }

    // Left: branch info
    final branch = appState.git.currentBranch ?? '(no branch)';
    var statusText = ' $branch';
    if (appState.git.isMerging) statusText += ' | MERGING';
    if (appState.git.isRebasing) statusText += ' | REBASING';

    for (var i = 0; i < statusText.length && i < area.width; i++) {
      canvas.drawChar(area.x + i, area.y, statusText[i], style);
    }

    // Right: error/status message or help hint
    final rightText = appState.ui.errorMessage ??
        appState.ui.statusMessage ??
        '? for help';
    final rightStart = area.right - rightText.length - 1;
    if (rightStart > area.x + statusText.length) {
      for (var i = 0; i < rightText.length; i++) {
        final msgStyle = appState.ui.errorMessage != null
            ? const Style(foreground: Color.red, inverse: true)
            : style;
        canvas.drawChar(rightStart + i, area.y, rightText[i], msgStyle);
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
