import '../git_command_runner.dart';
import '../models/git_remote.dart';

/// Commands for working with git remotes and remote operations.
class RemoteCommands {
  final GitCommandRunner _runner;

  RemoteCommands(this._runner);

  /// List all configured remotes with their URLs.
  Future<List<GitRemote>> getRemotes() async {
    final result = await _runner.runAllowFailure('remote', ['-v']);
    if (result.exitCode != 0 || result.stdout.isEmpty) return [];

    // Output format: "origin\thttps://... (fetch)\norigin\thttps://... (push)"
    final remoteMap = <String, _RemoteUrls>{};

    for (final line in result.stdout.split('\n')) {
      if (line.trim().isEmpty) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 3) continue;

      final name = parts[0];
      final url = parts[1];
      final type = parts[2]; // "(fetch)" or "(push)"

      remoteMap.putIfAbsent(name, () => _RemoteUrls());
      if (type == '(fetch)') {
        remoteMap[name]!.fetchUrl = url;
      } else if (type == '(push)') {
        remoteMap[name]!.pushUrl = url;
      }
    }

    return remoteMap.entries.map((e) {
      return GitRemote(
        name: e.key,
        fetchUrl: e.value.fetchUrl ?? '',
        pushUrl: e.value.pushUrl ?? e.value.fetchUrl ?? '',
      );
    }).toList();
  }

  /// Push to a remote.
  Future<void> push({
    String? remote,
    String? branch,
    bool force = false,
    bool setUpstream = false,
  }) async {
    final args = <String>[];
    if (force) args.add('--force');
    if (setUpstream) args.add('--set-upstream');
    if (remote != null) args.add(remote);
    if (branch != null) args.add(branch);
    await _runner.run('push', args);
  }

  /// Pull from a remote.
  Future<void> pull({
    String? remote,
    String? branch,
    bool rebase = false,
  }) async {
    final args = <String>[];
    if (rebase) args.add('--rebase');
    if (remote != null) args.add(remote);
    if (branch != null) args.add(branch);
    await _runner.run('pull', args);
  }

  /// Fetch from one or all remotes.
  Future<void> fetch({
    String? remote,
    bool all = false,
    bool prune = false,
  }) async {
    final args = <String>[];
    if (all) args.add('--all');
    if (prune) args.add('--prune');
    if (remote != null && !all) args.add(remote);
    await _runner.run('fetch', args);
  }
}

class _RemoteUrls {
  String? fetchUrl;
  String? pushUrl;
}
