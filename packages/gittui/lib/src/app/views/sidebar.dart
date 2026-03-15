import 'package:dtui/dtui.dart';

import '../../git/models/git_branch.dart';
import '../../git/models/git_commit.dart';
import '../../git/models/git_file.dart';
import '../../git/models/git_stash.dart';
import '../state/app_state.dart';
import '../state/ui_state.dart';

class Sidebar extends Widget {
  final AppState appState;
  final int selectedFileIndex;
  final int selectedBranchIndex;
  final int selectedCommitIndex;
  final int selectedStashIndex;

  Sidebar({
    required this.appState,
    this.selectedFileIndex = 0,
    this.selectedBranchIndex = 0,
    this.selectedCommitIndex = 0,
    this.selectedStashIndex = 0,
  });

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0) return;

    // Draw tab bar at top
    _renderTabBar(canvas, Rect(area.x, area.y, area.width, 1));

    // Draw content below tab bar
    if (area.height > 1) {
      final contentArea = Rect(area.x, area.y + 1, area.width, area.height - 1);
      switch (appState.ui.activeTab) {
        case SidebarTab.status:
          _renderStatus(canvas, contentArea);
        case SidebarTab.files:
          _renderFiles(canvas, contentArea);
        case SidebarTab.branches:
          _renderBranches(canvas, contentArea);
        case SidebarTab.commits:
          _renderCommits(canvas, contentArea);
        case SidebarTab.stash:
          _renderStash(canvas, contentArea);
      }
    }
  }

  void _renderTabBar(Canvas canvas, Rect area) {
    var x = area.x;
    for (final tab in SidebarTab.values) {
      final isActive = tab == appState.ui.activeTab;
      final label = ' ${tab.shortcut}:${tab.label} ';
      final style = isActive
          ? const Style(bold: true, inverse: true)
          : const Style(dim: true);
      for (var i = 0; i < label.length && x < area.right; i++) {
        canvas.drawChar(x, area.y, label[i], style);
        x++;
      }
    }
    // Clear rest of line
    final clearStyle = Style.none;
    while (x < area.right) {
      canvas.drawChar(x, area.y, ' ', clearStyle);
      x++;
    }
  }

  void _renderStatus(Canvas canvas, Rect area) {
    final lines = <String>[
      'Branch: ${appState.git.currentBranch ?? "(detached)"}',
      'Files changed: ${appState.git.files.length}',
    ];
    if (appState.git.isMerging) lines.add('MERGING');
    if (appState.git.isRebasing) lines.add('REBASING');

    for (var i = 0; i < lines.length && i < area.height; i++) {
      canvas.drawText(area.x, area.y + i, lines[i], Style.none);
    }
  }

  void _renderFiles(Canvas canvas, Rect area) {
    _renderList(
      canvas,
      area,
      appState.git.files,
      selectedFileIndex,
      (GitFile f) => '${f.statusDisplay} ${f.path}',
      (GitFile f) => _fileStyle(f),
    );
  }

  void _renderBranches(Canvas canvas, Rect area) {
    _renderList(
      canvas,
      area,
      appState.git.branches,
      selectedBranchIndex,
      (GitBranch b) => '${b.isHead ? "* " : "  "}${b.displayName}',
      (GitBranch b) => b.isHead ? const Style(foreground: Color.green) : Style.none,
    );
  }

  void _renderCommits(Canvas canvas, Rect area) {
    _renderList(
      canvas,
      area,
      appState.git.commits,
      selectedCommitIndex,
      (GitCommit c) => '${c.shortHash} ${c.subject}',
      (_) => Style.none,
    );
  }

  void _renderStash(Canvas canvas, Rect area) {
    _renderList(
      canvas,
      area,
      appState.git.stashes,
      selectedStashIndex,
      (GitStash s) => 'stash@{${s.index}}: ${s.message}',
      (_) => Style.none,
    );
  }

  void _renderList<T>(
    Canvas canvas,
    Rect area,
    List<T> items,
    int selectedIndex,
    String Function(T) labelFn,
    Style Function(T) styleFn,
  ) {
    if (items.isEmpty) {
      canvas.drawText(area.x, area.y, '  (empty)', const Style(dim: true));
      return;
    }

    // Simple scroll calculation
    var scrollOffset = 0;
    if (selectedIndex >= area.height) {
      scrollOffset = selectedIndex - area.height + 1;
    }

    for (var i = 0; i < area.height; i++) {
      final itemIndex = scrollOffset + i;
      if (itemIndex >= items.length) break;

      final item = items[itemIndex];
      final label = labelFn(item);
      final isSelected = itemIndex == selectedIndex;
      var style = styleFn(item);
      if (isSelected) {
        style = style.merge(const Style(inverse: true));
      }

      // Clear line
      for (var x = area.x; x < area.right; x++) {
        canvas.drawChar(x, area.y + i, ' ', isSelected ? style : Style.none);
      }

      // Draw label, truncated
      final maxLen = area.width;
      for (var j = 0; j < label.length && j < maxLen; j++) {
        canvas.drawChar(area.x + j, area.y + i, label[j], style);
      }
    }
  }

  Style _fileStyle(GitFile file) {
    switch (file.worktreeStatus) {
      case FileStatus.modified:
        return const Style(foreground: Color.yellow);
      case FileStatus.added:
      case FileStatus.untracked:
        return const Style(foreground: Color.green);
      case FileStatus.deleted:
        return const Style(foreground: Color.red);
      case FileStatus.renamed:
        return const Style(foreground: Color.cyan);
      default:
        if (file.hasStagedChanges) {
          return const Style(foreground: Color.green);
        }
        return Style.none;
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(40, constraints.maxHeight);
  }

  @override
  bool handleEvent(InputEvent event) => false;
}
