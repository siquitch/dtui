/// Status of a file in the git index or worktree.
enum FileStatus {
  untracked,
  modified,
  added,
  deleted,
  renamed,
  copied,
  typeChanged,
  unmerged,
}

/// Whether a file is staged, unstaged, or in a mixed state.
enum StagingStatus {
  staged,
  unstaged,
  partiallyStaged,
  conflicted,
}

/// Represents a file tracked by git with its index and worktree status.
class GitFile {
  final String path;
  final String? oldPath;
  final FileStatus indexStatus;
  final FileStatus worktreeStatus;

  const GitFile({
    required this.path,
    this.oldPath,
    required this.indexStatus,
    required this.worktreeStatus,
  });

  /// Derive the overall staging status from the index and worktree statuses.
  StagingStatus get stagingStatus {
    if (indexStatus == FileStatus.unmerged ||
        worktreeStatus == FileStatus.unmerged) {
      return StagingStatus.conflicted;
    }
    final hasIndex = indexStatus != FileStatus.untracked;
    final hasWorktree = worktreeStatus != FileStatus.untracked;
    if (hasIndex && hasWorktree) return StagingStatus.partiallyStaged;
    if (hasIndex) return StagingStatus.staged;
    return StagingStatus.unstaged;
  }

  /// Whether the file is tracked by git (not untracked in both index and worktree).
  bool get isTracked =>
      indexStatus != FileStatus.untracked ||
      worktreeStatus != FileStatus.untracked &&
          worktreeStatus != FileStatus.added;

  /// Whether there are unstaged changes in the worktree.
  bool get hasUnstagedChanges =>
      worktreeStatus != FileStatus.untracked || !isTracked;

  /// Whether there are staged changes in the index.
  bool get hasStagedChanges => indexStatus != FileStatus.untracked;

  /// Short two-character status display, matching `git status --short` format.
  String get statusDisplay {
    final x = _statusChar(indexStatus);
    final y = _statusChar(worktreeStatus);
    return '$x$y';
  }

  static String _statusChar(FileStatus status) {
    switch (status) {
      case FileStatus.untracked:
        return '?';
      case FileStatus.modified:
        return 'M';
      case FileStatus.added:
        return 'A';
      case FileStatus.deleted:
        return 'D';
      case FileStatus.renamed:
        return 'R';
      case FileStatus.copied:
        return 'C';
      case FileStatus.typeChanged:
        return 'T';
      case FileStatus.unmerged:
        return 'U';
    }
  }

  /// Parse a porcelain v2 status character into a [FileStatus].
  static FileStatus parseStatusChar(String char) {
    switch (char) {
      case 'M':
        return FileStatus.modified;
      case 'A':
        return FileStatus.added;
      case 'D':
        return FileStatus.deleted;
      case 'R':
        return FileStatus.renamed;
      case 'C':
        return FileStatus.copied;
      case 'T':
        return FileStatus.typeChanged;
      case 'U':
        return FileStatus.unmerged;
      case '.':
      case ' ':
        return FileStatus.untracked;
      default:
        return FileStatus.untracked;
    }
  }

  @override
  String toString() => 'GitFile($statusDisplay $path)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitFile &&
        other.path == path &&
        other.oldPath == oldPath &&
        other.indexStatus == indexStatus &&
        other.worktreeStatus == worktreeStatus;
  }

  @override
  int get hashCode => Object.hash(path, oldPath, indexStatus, worktreeStatus);
}
