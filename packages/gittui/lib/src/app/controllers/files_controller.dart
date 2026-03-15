import '../../git/models/git_file.dart';
import 'controller.dart';

class FilesController extends Controller {
  int selectedIndex = 0;

  FilesController({
    required super.repo,
    required super.getState,
    required super.setState,
  });

  List<GitFile> get files => state.git.files;

  GitFile? get selectedFile {
    if (files.isEmpty || selectedIndex < 0 || selectedIndex >= files.length) {
      return null;
    }
    return files[selectedIndex];
  }

  Future<void> refresh() async {
    try {
      final files = await repo.status.getStatus();
      updateGitState((g) => g.copyWith(files: files));
      if (selectedIndex >= files.length && files.isNotEmpty) {
        selectedIndex = files.length - 1;
      }
    } on Exception {
      // Silently handle — status may fail if not in a git repo
    }
  }

  Future<void> stageSelected() async {
    final file = selectedFile;
    if (file == null) return;
    await repo.files.stageFile(file.path);
    await refresh();
  }

  Future<void> unstageSelected() async {
    final file = selectedFile;
    if (file == null) return;
    await repo.files.unstageFile(file.path);
    await refresh();
  }

  Future<void> toggleStageSelected() async {
    final file = selectedFile;
    if (file == null) return;
    if (file.hasStagedChanges && !file.hasUnstagedChanges) {
      await unstageSelected();
    } else {
      await stageSelected();
    }
  }

  Future<void> stageAll() async {
    await repo.files.stageAll();
    await refresh();
  }

  Future<void> unstageAll() async {
    await repo.files.unstageAll();
    await refresh();
  }

  Future<void> discardSelected() async {
    final file = selectedFile;
    if (file == null) return;
    if (file.worktreeStatus == FileStatus.untracked) {
      await repo.files.discardUntracked(file.path);
    } else {
      await repo.files.discardFile(file.path);
    }
    await refresh();
  }

  Future<void> loadDiffForSelected() async {
    final file = selectedFile;
    if (file == null) {
      updateGitState((g) => g.copyWith(clearSelectedDiff: true));
      return;
    }
    try {
      final diff = await repo.diff.diffFile(
        file.path,
        staged: file.hasStagedChanges && !file.hasUnstagedChanges,
      );
      updateGitState((g) => g.copyWith(selectedDiff: diff));
    } on Exception {
      updateGitState((g) => g.copyWith(clearSelectedDiff: true));
    }
  }
}
