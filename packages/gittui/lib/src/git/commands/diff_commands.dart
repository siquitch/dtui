import '../git_command_runner.dart';
import '../models/git_diff.dart';

/// Commands for viewing and applying diffs.
class DiffCommands {
  final GitCommandRunner _runner;

  DiffCommands(this._runner);

  /// Get the diff for a single file.
  ///
  /// If [staged] is true, shows the staged (cached) diff.
  Future<GitDiff> diffFile(String path, {bool staged = false}) async {
    final args = <String>[];
    if (staged) args.add('--cached');
    args.addAll(['--', path]);

    final result = await _runner.runAllowFailure('diff', args);
    if (result.stdout.isEmpty) {
      return GitDiff(newFile: path);
    }
    return GitDiff.parse(result.stdout);
  }

  /// Get diffs for all changed files.
  ///
  /// If [staged] is true, shows only staged (cached) diffs.
  Future<List<GitDiff>> diffAll({bool staged = false}) async {
    final args = <String>[];
    if (staged) args.add('--cached');

    final result = await _runner.runAllowFailure('diff', args);
    if (result.stdout.isEmpty) return [];
    return GitDiff.parseMulti(result.stdout);
  }

  /// Get the diff for a specific commit compared to its parent.
  Future<GitDiff> diffCommit(String hash) async {
    final result = await _runner.run('diff', ['$hash~1', hash]);
    if (result.stdout.isEmpty) {
      return const GitDiff();
    }
    return GitDiff.parse(result.stdout);
  }

  /// Get a diffstat summary.
  Future<String> diffStat({bool staged = false}) async {
    final args = ['--stat'];
    if (staged) args.add('--cached');

    final result = await _runner.runAllowFailure('diff', args);
    return result.stdout;
  }

  /// Stage a specific hunk by applying a patch to the index.
  Future<void> stageHunk(String path, String patchContent) async {
    await _runner.runWithStdin('apply', ['--cached', '-'], patchContent);
  }

  /// Unstage a specific hunk by reverse-applying a patch from the index.
  Future<void> unstageHunk(String path, String patchContent) async {
    await _runner.runWithStdin(
      'apply',
      ['--cached', '--reverse', '-'],
      patchContent,
    );
  }
}
