import '../git_command_runner.dart';

/// Commands for creating and manipulating commits.
class CommitCommands {
  final GitCommandRunner _runner;

  CommitCommands(this._runner);

  /// Create a new commit with the given message.
  Future<void> commit(String message) async {
    await _runner.run('commit', ['-m', message]);
  }

  /// Amend the most recent commit, optionally changing the message.
  Future<void> commitAmend({String? message}) async {
    if (message != null) {
      await _runner.run('commit', ['--amend', '-m', message]);
    } else {
      await _runner.run('commit', ['--amend', '--no-edit']);
    }
  }

  /// Create an empty commit (no changes) with the given message.
  Future<void> commitEmpty(String message) async {
    await _runner.run('commit', ['--allow-empty', '-m', message]);
  }

  /// Get the full commit message for a given commit hash.
  Future<String> getCommitMessage(String hash) async {
    final result = await _runner.run('log', ['-1', '--format=%B', hash]);
    return result.stdout.trim();
  }

  /// Reword the HEAD commit with a new message.
  ///
  /// This only works for the HEAD commit. For older commits, an interactive
  /// rebase is required.
  Future<void> rewordCommit(String hash, String message) async {
    // Verify we are rewriting HEAD
    final headResult = await _runner.run('rev-parse', ['HEAD']);
    final headHash = headResult.stdout.trim();
    final targetResult = await _runner.run('rev-parse', [hash]);
    final targetHash = targetResult.stdout.trim();

    if (headHash != targetHash) {
      throw GitCommandException(
        exitCode: 1,
        stderr:
            'rewordCommit only supports HEAD. '
            'Use interactive rebase for older commits.',
        command: 'rewordCommit',
      );
    }

    await _runner.run('commit', ['--amend', '-m', message]);
  }

  /// Reset the current branch to a ref, keeping changes staged.
  Future<void> resetSoft(String ref) async {
    await _runner.run('reset', ['--soft', ref]);
  }

  /// Reset the current branch to a ref, unstaging changes.
  Future<void> resetMixed(String ref) async {
    await _runner.run('reset', ['--mixed', ref]);
  }

  /// Reset the current branch to a ref, discarding all changes.
  Future<void> resetHard(String ref) async {
    await _runner.run('reset', ['--hard', ref]);
  }
}
