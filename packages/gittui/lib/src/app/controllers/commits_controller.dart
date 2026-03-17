import '../../git/models/git_commit.dart';
import 'controller.dart';

class CommitsController extends Controller {
  int selectedIndex = 0;

  CommitsController({
    required super.repo,
    required super.getState,
    required super.setState,
  });

  List<GitCommit> get commits => state.git.commits;

  GitCommit? get selectedCommit {
    if (commits.isEmpty ||
        selectedIndex < 0 ||
        selectedIndex >= commits.length) {
      return null;
    }
    return commits[selectedIndex];
  }

  Future<void> refresh() async {
    try {
      final commits = await repo.log.getLog();
      updateGitState((g) => g.copyWith(commits: commits));
      if (selectedIndex >= commits.length && commits.isNotEmpty) {
        selectedIndex = commits.length - 1;
      }
    } on Exception {
      // Handle gracefully — may have no commits
    }
  }

  Future<void> commit(String message) async {
    await repo.commits.commit(message);
    await refresh();
  }

  Future<void> amendCommit({String? message}) async {
    await repo.commits.commitAmend(message: message);
    await refresh();
  }

  Future<void> resetToSelected({required String mode}) async {
    final commit = selectedCommit;
    if (commit == null) return;
    switch (mode) {
      case 'soft':
        await repo.commits.resetSoft(commit.hash);
      case 'mixed':
        await repo.commits.resetMixed(commit.hash);
      case 'hard':
        await repo.commits.resetHard(commit.hash);
    }
    await refresh();
  }
}
