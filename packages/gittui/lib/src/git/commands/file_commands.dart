import 'dart:io';

import 'package:path/path.dart' as p;

import '../git_command_runner.dart';

/// Commands for staging, unstaging, and discarding file changes.
class FileCommands {
  final GitCommandRunner _runner;

  FileCommands(this._runner);

  /// Stage a single file.
  Future<void> stageFile(String path) async {
    await _runner.run('add', ['--', path]);
  }

  /// Stage all changes (tracked and untracked).
  Future<void> stageAll() async {
    await _runner.run('add', ['-A']);
  }

  /// Unstage a single file (reset to HEAD).
  Future<void> unstageFile(String path) async {
    await _runner.run('reset', ['HEAD', '--', path]);
  }

  /// Unstage all staged changes.
  Future<void> unstageAll() async {
    await _runner.run('reset', ['HEAD']);
  }

  /// Discard unstaged changes to a tracked file.
  Future<void> discardFile(String path) async {
    await _runner.run('checkout', ['--', path]);
  }

  /// Remove an untracked file or directory.
  Future<void> discardUntracked(String path) async {
    final fullPath = p.join(_runner.workingDirectory, path);
    final type = FileSystemEntity.typeSync(fullPath);
    if (type == FileSystemEntityType.directory) {
      await _runner.run('clean', ['-fd', '--', path]);
    } else {
      final file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Append a path to the repository's .gitignore file.
  Future<void> ignoreFile(String path) async {
    final gitignorePath = p.join(_runner.workingDirectory, '.gitignore');
    final file = File(gitignorePath);
    String content = '';
    if (await file.exists()) {
      content = await file.readAsString();
      if (!content.endsWith('\n') && content.isNotEmpty) {
        content += '\n';
      }
    }
    content += '$path\n';
    await file.writeAsString(content);
  }
}
