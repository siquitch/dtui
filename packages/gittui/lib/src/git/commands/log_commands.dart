import '../git_command_runner.dart';
import '../models/git_commit.dart';
import '../models/git_log_entry.dart';

/// Commands for viewing commit history and reflogs.
class LogCommands {
  final GitCommandRunner _runner;

  LogCommands(this._runner);

  /// Get the commit log for the current or specified branch.
  Future<List<GitCommit>> getLog({int limit = 100, String? branch}) async {
    // Use NUL-separated fields to avoid ambiguity in parsing.
    // Format: hash, short hash, subject, body, author name, author email,
    //         author date (ISO), parent hashes, decorations
    const separator = '%x00';
    const format = '%H$separator%h$separator%s$separator%b$separator'
        '%an$separator%ae$separator%aI$separator%P$separator%D';

    final args = [
      '--format=$format',
      '-n',
      '$limit',
      '--decorate=short',
    ];
    if (branch != null) args.add(branch);

    final result = await _runner.runAllowFailure('log', args);
    if (result.exitCode != 0 || result.stdout.isEmpty) return [];

    return _parseLog(result.stdout);
  }

  List<GitCommit> _parseLog(String output) {
    if (output.trim().isEmpty) return [];

    final commits = <GitCommit>[];
    // Split the output into records. Each record starts with a 40-char hex
    // hash followed by \x00. We find these boundaries.
    final recordPattern = RegExp(r'(?:^|\n)([0-9a-f]{40})\x00');
    final matches = recordPattern.allMatches(output).toList();

    for (int i = 0; i < matches.length; i++) {
      final start = matches[i].start;
      final end = i + 1 < matches.length ? matches[i + 1].start : output.length;
      final record = output.substring(start, end).trimLeft();

      final parts = record.split('\x00');
      if (parts.length < 9) continue;

      final hash = parts[0];
      final shortHash = parts[1];
      final subject = parts[2];
      final body = parts[3].trim();
      final authorName = parts[4];
      final authorEmail = parts[5];
      final dateStr = parts[6];
      final parentStr = parts[7];
      final decorations = parts[8].trim();

      DateTime authorDate;
      try {
        authorDate = DateTime.parse(dateStr);
      } catch (_) {
        authorDate = DateTime.now();
      }

      final parentHashes = parentStr.trim().isEmpty
          ? <String>[]
          : parentStr.trim().split(' ');

      // Parse tags and refs from decorations like "HEAD -> main, tag: v1.0, origin/main"
      final tags = <String>[];
      final refs = <String>[];
      if (decorations.isNotEmpty) {
        for (final part in decorations.split(',')) {
          final trimmed = part.trim();
          if (trimmed.startsWith('tag: ')) {
            tags.add(trimmed.substring(5));
          }
          if (trimmed.isNotEmpty) {
            refs.add(trimmed);
          }
        }
      }

      commits.add(GitCommit(
        hash: hash,
        shortHash: shortHash,
        subject: subject,
        body: body,
        authorName: authorName,
        authorEmail: authorEmail,
        authorDate: authorDate,
        parentHashes: parentHashes,
        tags: tags,
        refs: refs,
      ));
    }

    return commits;
  }

  /// Get the reflog.
  Future<List<GitLogEntry>> getReflog({int limit = 100}) async {
    // Format: hash, short hash, action, message, date
    const format = '%H%x00%h%x00%gs%x00%gd%x00%aI';

    final result = await _runner.runAllowFailure('reflog', [
      '--format=$format',
      '-n',
      '$limit',
    ]);

    if (result.exitCode != 0 || result.stdout.isEmpty) return [];

    final entries = <GitLogEntry>[];
    for (final line in result.stdout.split('\n')) {
      if (line.trim().isEmpty) continue;

      final parts = line.split('\x00');
      if (parts.length < 5) continue;

      final hash = parts[0];
      final shortHash = parts[1];
      final actionAndMessage = parts[2];
      // parts[3] is the reflog selector like "HEAD@{0}"
      final dateStr = parts[4];

      DateTime date;
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
        date = DateTime.now();
      }

      // Split action and message: "commit: some message" or "checkout: ..."
      String action;
      String message;
      final colonIndex = actionAndMessage.indexOf(': ');
      if (colonIndex >= 0) {
        action = actionAndMessage.substring(0, colonIndex);
        message = actionAndMessage.substring(colonIndex + 2);
      } else {
        action = actionAndMessage;
        message = '';
      }

      entries.add(GitLogEntry(
        hash: hash,
        shortHash: shortHash,
        action: action,
        message: message,
        date: date,
      ));
    }

    return entries;
  }

  /// List all tags.
  Future<List<String>> getTags() async {
    final result = await _runner.runAllowFailure('tag', ['-l']);
    if (result.exitCode != 0 || result.stdout.isEmpty) return [];
    return result.stdout
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
  }

  /// Get full details for a single commit.
  Future<GitCommit> getCommit(String hash) async {
    const separator = '%x00';
    const format = '%H$separator%h$separator%s$separator%b$separator'
        '%an$separator%ae$separator%aI$separator%P$separator%D';

    final result = await _runner.run('log', [
      '-1',
      '--format=$format',
      hash,
    ]);

    final parsed = _parseLog(result.stdout);
    if (parsed.isEmpty) {
      throw GitCommandException(
        exitCode: 1,
        stderr: 'Could not parse commit $hash',
        command: 'log -1 $hash',
      );
    }
    return parsed.first;
  }
}
