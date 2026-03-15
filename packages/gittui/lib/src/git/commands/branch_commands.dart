import '../git_command_runner.dart';
import '../models/git_branch.dart';

/// Commands for branch management.
class BranchCommands {
  final GitCommandRunner _runner;

  BranchCommands(this._runner);

  /// List all branches (local and remote) with metadata.
  Future<List<GitBranch>> getBranches() async {
    // Use a custom format to get all the data we need.
    // Fields: refname:short, objectname:short, subject, HEAD, upstream:short,
    // upstream:track
    const format = '%(HEAD)%00%(refname:short)%00%(objectname:short)%00'
        '%(subject)%00%(upstream:short)%00%(upstream:track)%00%(refname)';

    final result = await _runner.run('branch', [
      '-a',
      '--format=$format',
    ]);

    if (result.stdout.isEmpty) return [];

    final branches = <GitBranch>[];

    for (final line in result.stdout.split('\n')) {
      if (line.trim().isEmpty) continue;

      final parts = line.split('\x00');
      if (parts.length < 7) continue;

      final isHead = parts[0].trim() == '*';
      final name = parts[1].trim();
      final commitHash = parts[2].trim();
      final commitSubject = parts[3].trim();
      final upstream = parts[4].trim();
      final trackInfo = parts[5].trim();
      final fullRef = parts[6].trim();

      final isRemote = fullRef.startsWith('refs/remotes/');
      String? remoteName;
      if (isRemote) {
        // Extract remote name from refs/remotes/<remote>/<branch>
        final afterRemotes = fullRef.substring('refs/remotes/'.length);
        final slashIndex = afterRemotes.indexOf('/');
        if (slashIndex > 0) {
          remoteName = afterRemotes.substring(0, slashIndex);
        }
      }

      // Parse ahead/behind from track info like "[ahead 3, behind 2]"
      int? ahead;
      int? behind;
      if (trackInfo.isNotEmpty) {
        final aheadMatch = RegExp(r'ahead (\d+)').firstMatch(trackInfo);
        final behindMatch = RegExp(r'behind (\d+)').firstMatch(trackInfo);
        if (aheadMatch != null) ahead = int.parse(aheadMatch.group(1)!);
        if (behindMatch != null) behind = int.parse(behindMatch.group(1)!);
      }

      branches.add(GitBranch(
        name: name,
        remoteName: remoteName,
        upstream: upstream.isEmpty ? null : upstream,
        commitHash: commitHash.isEmpty ? null : commitHash,
        commitSubject: commitSubject.isEmpty ? null : commitSubject,
        isHead: isHead,
        isRemote: isRemote,
        ahead: ahead,
        behind: behind,
      ));
    }

    return branches;
  }

  /// Create a new branch.
  Future<void> createBranch(String name, {String? startPoint}) async {
    final args = [name];
    if (startPoint != null) args.add(startPoint);
    await _runner.run('branch', args);
  }

  /// Checkout an existing branch.
  Future<void> checkoutBranch(String name) async {
    await _runner.run('checkout', [name]);
  }

  /// Delete a branch.
  Future<void> deleteBranch(String name, {bool force = false}) async {
    await _runner.run('branch', [force ? '-D' : '-d', name]);
  }

  /// Rename a branch.
  Future<void> renameBranch(String oldName, String newName) async {
    await _runner.run('branch', ['-m', oldName, newName]);
  }

  /// Merge a branch into the current branch.
  Future<void> mergeBranch(String name) async {
    await _runner.run('merge', [name]);
  }

  /// Get information about the currently checked out branch, or null if detached.
  Future<GitBranch?> getCurrentBranch() async {
    final branches = await getBranches();
    for (final branch in branches) {
      if (branch.isHead) return branch;
    }
    return null;
  }
}
