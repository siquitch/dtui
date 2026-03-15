import '../git_command_runner.dart';

/// Commands for git rebase operations.
class RebaseCommands {
  final GitCommandRunner _runner;

  RebaseCommands(this._runner);

  /// Rebase the current branch onto another branch or commit.
  Future<void> rebase(String onto) async {
    await _runner.run('rebase', [onto]);
  }

  /// Start an interactive rebase onto a given ref.
  Future<void> rebaseInteractive(String onto) async {
    await _runner.run('rebase', ['-i', onto]);
  }

  /// Continue a rebase after resolving conflicts.
  Future<void> rebaseContinue() async {
    await _runner.run('rebase', ['--continue']);
  }

  /// Abort an in-progress rebase.
  Future<void> rebaseAbort() async {
    await _runner.run('rebase', ['--abort']);
  }

  /// Skip the current patch during a rebase.
  Future<void> rebaseSkip() async {
    await _runner.run('rebase', ['--skip']);
  }
}
