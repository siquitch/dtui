import '../../git/models/git_branch.dart';
import '../../git/models/git_commit.dart';
import '../../git/models/git_diff.dart';
import '../../git/models/git_file.dart';
import '../../git/models/git_remote.dart';
import '../../git/models/git_stash.dart';

class GitState {
  final List<GitFile> files;
  final List<GitBranch> branches;
  final List<GitCommit> commits;
  final List<GitStash> stashes;
  final List<GitRemote> remotes;
  final String? currentBranch;
  final String? repoRoot;
  final bool isMerging;
  final bool isRebasing;
  final GitDiff? selectedDiff;

  const GitState({
    this.files = const [],
    this.branches = const [],
    this.commits = const [],
    this.stashes = const [],
    this.remotes = const [],
    this.currentBranch,
    this.repoRoot,
    this.isMerging = false,
    this.isRebasing = false,
    this.selectedDiff,
  });

  GitState copyWith({
    List<GitFile>? files,
    List<GitBranch>? branches,
    List<GitCommit>? commits,
    List<GitStash>? stashes,
    List<GitRemote>? remotes,
    String? currentBranch,
    String? repoRoot,
    bool? isMerging,
    bool? isRebasing,
    GitDiff? selectedDiff,
    bool clearSelectedDiff = false,
  }) {
    return GitState(
      files: files ?? this.files,
      branches: branches ?? this.branches,
      commits: commits ?? this.commits,
      stashes: stashes ?? this.stashes,
      remotes: remotes ?? this.remotes,
      currentBranch: currentBranch ?? this.currentBranch,
      repoRoot: repoRoot ?? this.repoRoot,
      isMerging: isMerging ?? this.isMerging,
      isRebasing: isRebasing ?? this.isRebasing,
      selectedDiff: clearSelectedDiff
          ? null
          : (selectedDiff ?? this.selectedDiff),
    );
  }
}
