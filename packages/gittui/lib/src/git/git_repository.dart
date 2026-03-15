import 'git_command_runner.dart';
import 'commands/branch_commands.dart';
import 'commands/commit_commands.dart';
import 'commands/config_commands.dart';
import 'commands/diff_commands.dart';
import 'commands/file_commands.dart';
import 'commands/log_commands.dart';
import 'commands/rebase_commands.dart';
import 'commands/remote_commands.dart';
import 'commands/stash_commands.dart';
import 'commands/status_commands.dart';

/// Facade over all git command classes for a single repository.
///
/// Usage:
/// ```dart
/// final repo = await GitRepository.open('/path/to/repo');
/// final files = await repo.status.getStatus();
/// await repo.files.stageAll();
/// await repo.commits.commit('Initial commit');
/// ```
class GitRepository {
  final String path;
  late final GitCommandRunner _runner;
  late final StatusCommands _status;
  late final FileCommands _files;
  late final CommitCommands _commits;
  late final BranchCommands _branches;
  late final StashCommands _stash;
  late final RemoteCommands _remotes;
  late final RebaseCommands _rebase;
  late final DiffCommands _diff;
  late final LogCommands _log;
  late final ConfigCommands _config;

  GitRepository._(this.path) {
    _runner = GitCommandRunner(path);
    _status = StatusCommands(_runner);
    _files = FileCommands(_runner);
    _commits = CommitCommands(_runner);
    _branches = BranchCommands(_runner);
    _stash = StashCommands(_runner);
    _remotes = RemoteCommands(_runner);
    _rebase = RebaseCommands(_runner);
    _diff = DiffCommands(_runner);
    _log = LogCommands(_runner);
    _config = ConfigCommands(_runner);
  }

  /// Open a git repository at the given path.
  ///
  /// Validates that the path is inside a git work tree and resolves to the
  /// repository root.
  ///
  /// Throws [GitCommandException] if the path is not a git repository.
  static Future<GitRepository> open(String path) async {
    final tempRunner = GitCommandRunner(path);

    // Verify this is a git repo
    final checkResult = await tempRunner.run(
      'rev-parse',
      ['--is-inside-work-tree'],
    );
    if (checkResult.stdout.trim() != 'true') {
      throw GitCommandException(
        exitCode: 128,
        stderr: 'Not a git repository: $path',
        command: 'git rev-parse --is-inside-work-tree',
      );
    }

    // Resolve to the repo root
    final rootResult = await tempRunner.run(
      'rev-parse',
      ['--show-toplevel'],
    );
    final repoRoot = rootResult.stdout.trim();

    return GitRepository._(repoRoot);
  }

  /// The underlying command runner (for command log access, etc.).
  GitCommandRunner get runner => _runner;

  /// Status queries (file list, current branch, repo state).
  StatusCommands get status => _status;

  /// File operations (stage, unstage, discard).
  FileCommands get files => _files;

  /// Commit operations (commit, amend, reset).
  CommitCommands get commits => _commits;

  /// Branch operations (create, checkout, delete, merge).
  BranchCommands get branches => _branches;

  /// Stash operations (push, pop, apply, drop).
  StashCommands get stash => _stash;

  /// Remote operations (push, pull, fetch).
  RemoteCommands get remotes => _remotes;

  /// Rebase operations.
  RebaseCommands get rebase => _rebase;

  /// Diff operations (file diff, hunk staging).
  DiffCommands get diff => _diff;

  /// Log operations (commit log, reflog, tags).
  LogCommands get log => _log;

  /// Config operations (get, set, list).
  ConfigCommands get config => _config;
}
