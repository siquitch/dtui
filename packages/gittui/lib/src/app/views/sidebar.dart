import 'package:dtui/dtui.dart';

import '../../git/models/git_branch.dart';
import '../../git/models/git_commit.dart';
import '../../git/models/git_file.dart';
import '../state/app_state.dart';
import '../state/ui_state.dart';

class Sidebar extends Widget {
  final AppState appState;
  final int selectedFileIndex;
  final int selectedBranchIndex;
  final int selectedCommitIndex;

  Sidebar({
    required this.appState,
    this.selectedFileIndex = 0,
    this.selectedBranchIndex = 0,
    this.selectedCommitIndex = 0,
  });

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0) return;

    // Split available height into 3 panes
    final paneHeight = area.height ~/ 3;
    final remainder = area.height - paneHeight * 3;

    // Give extra rows to the first pane (files)
    final filesHeight = paneHeight + remainder;
    final branchesHeight = paneHeight;
    final commitsHeight = paneHeight;

    var y = area.y;

    // Files pane
    final filesArea = Rect(area.x, y, area.width, filesHeight);
    const focusedStyle = Style(foreground: Color.blue);
    final filesBorder = Border(
      child: _FilesList(
        files: appState.git.files,
        selectedIndex: selectedFileIndex,
      ),
      title: 'Files',
      focused: appState.ui.activePane == SidebarPane.files,
      focusedBorderStyle: focusedStyle,
      titleStyle: appState.ui.activePane == SidebarPane.files ? focusedStyle : Style.none,
    );
    filesBorder.render(canvas, filesArea);
    y += filesHeight;

    // Branches pane
    final branchesArea = Rect(area.x, y, area.width, branchesHeight);
    final branchesBorder = Border(
      child: _BranchesList(
        branches: appState.git.branches,
        selectedIndex: selectedBranchIndex,
      ),
      title: 'Branches',
      focused: appState.ui.activePane == SidebarPane.branches,
      focusedBorderStyle: focusedStyle,
      titleStyle: appState.ui.activePane == SidebarPane.branches ? focusedStyle : Style.none,
    );
    branchesBorder.render(canvas, branchesArea);
    y += branchesHeight;

    // Commits pane
    final commitsArea = Rect(area.x, y, area.width, commitsHeight);
    final commitsBorder = Border(
      child: _CommitsList(
        commits: appState.git.commits,
        selectedIndex: selectedCommitIndex,
      ),
      title: 'Commits',
      focused: appState.ui.activePane == SidebarPane.commits,
      focusedBorderStyle: focusedStyle,
      titleStyle: appState.ui.activePane == SidebarPane.commits ? focusedStyle : Style.none,
    );
    commitsBorder.render(canvas, commitsArea);
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(40, constraints.maxHeight);
  }

  @override
  bool handleEvent(InputEvent event) => false;
}

class _FilesList extends Widget {
  final List<GitFile> files;
  final int selectedIndex;

  _FilesList({required this.files, required this.selectedIndex});

  @override
  void render(Canvas canvas, Rect area) {
    _renderList(
      canvas,
      area,
      files,
      selectedIndex,
      (GitFile f) => '${f.statusDisplay} ${f.path}',
      (GitFile f) => _fileStyle(f),
    );
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
  (int, int) measure(BoxConstraints constraints) =>
      constraints.constrain(constraints.maxWidth, constraints.maxHeight);

  @override
  bool handleEvent(InputEvent event) => false;
}

class _BranchesList extends Widget {
  final List<GitBranch> branches;
  final int selectedIndex;

  _BranchesList({required this.branches, required this.selectedIndex});

  @override
  void render(Canvas canvas, Rect area) {
    _renderList(
      canvas,
      area,
      branches,
      selectedIndex,
      (GitBranch b) => '${b.isHead ? "* " : "  "}${b.displayName}',
      (GitBranch b) =>
          b.isHead ? const Style(foreground: Color.green) : Style.none,
    );
  }

  @override
  (int, int) measure(BoxConstraints constraints) =>
      constraints.constrain(constraints.maxWidth, constraints.maxHeight);

  @override
  bool handleEvent(InputEvent event) => false;
}

class _CommitsList extends Widget {
  final List<GitCommit> commits;
  final int selectedIndex;

  _CommitsList({required this.commits, required this.selectedIndex});

  @override
  void render(Canvas canvas, Rect area) {
    _renderList(
      canvas,
      area,
      commits,
      selectedIndex,
      (GitCommit c) => '${c.shortHash} ${c.subject}',
      (_) => Style.none,
    );
  }

  @override
  (int, int) measure(BoxConstraints constraints) =>
      constraints.constrain(constraints.maxWidth, constraints.maxHeight);

  @override
  bool handleEvent(InputEvent event) => false;
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
