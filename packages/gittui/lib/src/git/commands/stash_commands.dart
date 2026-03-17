import '../git_command_runner.dart';
import '../models/git_stash.dart';

/// Commands for working with the git stash.
class StashCommands {
  final GitCommandRunner _runner;

  StashCommands(this._runner);

  /// List all stash entries.
  Future<List<GitStash>> getStashes() async {
    final result = await _runner.runAllowFailure('stash', [
      'list',
      '--format=%H%x00%gd%x00%gs%x00%s',
    ]);

    if (result.exitCode != 0 || result.stdout.isEmpty) return [];

    final stashes = <GitStash>[];
    for (final line in result.stdout.split('\n')) {
      if (line.trim().isEmpty) continue;

      final parts = line.split('\x00');
      if (parts.length < 4) continue;

      final hash = parts[0];
      final refName = parts[1]; // e.g. "stash@{0}"
      final stashSubject = parts[2]; // e.g. "WIP on main: abc1234 msg"
      final message = parts[3];

      // Parse index from "stash@{N}"
      final indexMatch = RegExp(r'stash@\{(\d+)\}').firstMatch(refName);
      final index = indexMatch != null ? int.parse(indexMatch.group(1)!) : 0;

      // Parse branch name from stash subject like "WIP on main: ..." or
      // "On main: ..."
      var branchName = '';
      final branchMatch = RegExp(
        r'(?:WIP on|On) ([^:]+):',
      ).firstMatch(stashSubject);
      if (branchMatch != null) {
        branchName = branchMatch.group(1)!;
      }

      stashes.add(
        GitStash(
          index: index,
          message: message,
          hash: hash,
          branchName: branchName,
        ),
      );
    }

    return stashes;
  }

  /// Push changes to the stash.
  Future<void> stash({String? message, bool includeUntracked = true}) async {
    final args = ['push'];
    if (includeUntracked) args.add('--include-untracked');
    if (message != null) {
      args.addAll(['-m', message]);
    }
    await _runner.run('stash', args);
  }

  /// Pop a stash entry by index.
  Future<void> popStash(int index) async {
    await _runner.run('stash', ['pop', 'stash@{$index}']);
  }

  /// Apply a stash entry by index without removing it.
  Future<void> applyStash(int index) async {
    await _runner.run('stash', ['apply', 'stash@{$index}']);
  }

  /// Drop a stash entry by index.
  Future<void> dropStash(int index) async {
    await _runner.run('stash', ['drop', 'stash@{$index}']);
  }
}
