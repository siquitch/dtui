import 'dart:io';

import 'package:path/path.dart' as p;

import '../git_command_runner.dart';
import '../models/git_file.dart';

/// Commands for querying repository status.
class StatusCommands {
  final GitCommandRunner _runner;

  StatusCommands(this._runner);

  /// Get the status of all files in the repository using porcelain v2 format.
  Future<List<GitFile>> getStatus() async {
    final result = await _runner.run('status', ['--porcelain=v2', '-z']);
    final output = result.stdout;
    if (output.isEmpty) return [];

    final files = <GitFile>[];
    // Porcelain v2 with -z uses NUL as separator
    final entries = output.split('\x00');

    int i = 0;
    while (i < entries.length) {
      final entry = entries[i];
      if (entry.isEmpty) {
        i++;
        continue;
      }

      if (entry.startsWith('1 ')) {
        // Ordinary changed entry: 1 XY sub mH mI mW hH hI path
        final parts = entry.split(' ');
        if (parts.length >= 9) {
          final xy = parts[1];
          final path = parts.sublist(8).join(' ');
          files.add(GitFile(
            path: path,
            indexStatus: GitFile.parseStatusChar(xy[0]),
            worktreeStatus: GitFile.parseStatusChar(xy[1]),
          ));
        }
      } else if (entry.startsWith('2 ')) {
        // Renamed/copied entry: 2 XY sub mH mI mW hH hI Xscore path\torigPath
        // With -z the original path follows as next NUL-separated entry
        final parts = entry.split(' ');
        if (parts.length >= 10) {
          final xy = parts[1];
          final path = parts.sublist(9).join(' ');
          String? oldPath;
          if (i + 1 < entries.length) {
            oldPath = entries[i + 1];
            i++; // skip the old path entry
          }
          files.add(GitFile(
            path: path,
            oldPath: oldPath,
            indexStatus: GitFile.parseStatusChar(xy[0]),
            worktreeStatus: GitFile.parseStatusChar(xy[1]),
          ));
        }
      } else if (entry.startsWith('u ')) {
        // Unmerged entry: u XY sub m1 m2 m3 mW h1 h2 h3 path
        final parts = entry.split(' ');
        if (parts.length >= 11) {
          final path = parts.sublist(10).join(' ');
          files.add(GitFile(
            path: path,
            indexStatus: FileStatus.unmerged,
            worktreeStatus: FileStatus.unmerged,
          ));
        }
      } else if (entry.startsWith('? ')) {
        // Untracked: ? path
        final path = entry.substring(2);
        files.add(GitFile(
          path: path,
          indexStatus: FileStatus.untracked,
          worktreeStatus: FileStatus.untracked,
        ));
      }

      i++;
    }

    return files;
  }

  /// Get the name of the current branch, or empty string for detached HEAD.
  Future<String> getCurrentBranch() async {
    try {
      final result = await _runner.run('branch', ['--show-current']);
      return result.stdout.trim();
    } on GitCommandException {
      return '';
    }
  }

  /// Check if the current directory is inside a git work tree.
  Future<bool> isInsideWorkTree() async {
    try {
      final result = await _runner.run(
        'rev-parse',
        ['--is-inside-work-tree'],
      );
      return result.stdout.trim() == 'true';
    } on GitCommandException {
      return false;
    }
  }

  /// Get the absolute path of the repository root.
  Future<String> getRepoRoot() async {
    final result = await _runner.run('rev-parse', ['--show-toplevel']);
    return result.stdout.trim();
  }

  /// Check if a merge is in progress.
  Future<bool> isMerging() async {
    final mergeHead = File(p.join(_runner.workingDirectory, '.git', 'MERGE_HEAD'));
    return mergeHead.exists();
  }

  /// Check if a rebase is in progress.
  Future<bool> isRebasing() async {
    final rebaseMerge = Directory(
      p.join(_runner.workingDirectory, '.git', 'rebase-merge'),
    );
    final rebaseApply = Directory(
      p.join(_runner.workingDirectory, '.git', 'rebase-apply'),
    );
    return await rebaseMerge.exists() || await rebaseApply.exists();
  }
}
