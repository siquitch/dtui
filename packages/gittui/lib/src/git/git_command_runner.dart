import 'dart:io';

/// The result of running a git (or other) command.
class CommandResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  final String command;
  final Duration duration;

  const CommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.command,
    required this.duration,
  });

  bool get success => exitCode == 0;

  @override
  String toString() =>
      'CommandResult(exit=$exitCode, cmd=$command, duration=$duration)';
}

/// An entry in the command log for debugging and display.
class CommandLogEntry {
  final String command;
  final DateTime timestamp;
  final Duration duration;
  final int exitCode;
  final bool success;

  const CommandLogEntry({
    required this.command,
    required this.timestamp,
    required this.duration,
    required this.exitCode,
    required this.success,
  });

  @override
  String toString() => 'CommandLogEntry($command exit=$exitCode)';
}

/// Exception thrown when a git command exits with a non-zero code.
class GitCommandException implements Exception {
  final int exitCode;
  final String stderr;
  final String command;

  const GitCommandException({
    required this.exitCode,
    required this.stderr,
    required this.command,
  });

  @override
  String toString() =>
      'GitCommandException: "$command" exited with code $exitCode\n$stderr';
}

/// Runs git commands in a specific working directory and logs results.
class GitCommandRunner {
  final String workingDirectory;
  final List<CommandLogEntry> log = [];

  GitCommandRunner(this.workingDirectory);

  /// Run a git command with the given arguments.
  ///
  /// Throws [GitCommandException] if the command exits with a non-zero code.
  Future<CommandResult> run(String command, List<String> args) async {
    return runRaw('git', [command, ...args]);
  }

  /// Run an arbitrary executable with arguments.
  ///
  /// Throws [GitCommandException] if the command exits with a non-zero code.
  Future<CommandResult> runRaw(String executable, List<String> args) async {
    final cmdString = '$executable ${args.join(' ')}';
    final stopwatch = Stopwatch()..start();

    final result = await Process.run(
      executable,
      args,
      workingDirectory: workingDirectory,
    );

    stopwatch.stop();
    final duration = stopwatch.elapsed;
    final stdout = (result.stdout as String).trimRight();
    final stderr = (result.stderr as String).trimRight();

    log.add(
      CommandLogEntry(
        command: cmdString,
        timestamp: DateTime.now(),
        duration: duration,
        exitCode: result.exitCode,
        success: result.exitCode == 0,
      ),
    );

    final commandResult = CommandResult(
      exitCode: result.exitCode,
      stdout: stdout,
      stderr: stderr,
      command: cmdString,
      duration: duration,
    );

    if (result.exitCode != 0) {
      throw GitCommandException(
        exitCode: result.exitCode,
        stderr: stderr,
        command: cmdString,
      );
    }

    return commandResult;
  }

  /// Run a git command and pipe input to stdin.
  ///
  /// Throws [GitCommandException] if the command exits with a non-zero code.
  Future<CommandResult> runWithStdin(
    String command,
    List<String> args,
    String input,
  ) async {
    final fullArgs = [command, ...args];
    final cmdString = 'git ${fullArgs.join(' ')}';
    final stopwatch = Stopwatch()..start();

    final process = await Process.start(
      'git',
      fullArgs,
      workingDirectory: workingDirectory,
    );

    process.stdin.write(input);
    await process.stdin.close();

    final stdout = await process.stdout
        .transform(const SystemEncoding().decoder)
        .join();
    final stderr = await process.stderr
        .transform(const SystemEncoding().decoder)
        .join();
    final exitCode = await process.exitCode;

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    log.add(
      CommandLogEntry(
        command: cmdString,
        timestamp: DateTime.now(),
        duration: duration,
        exitCode: exitCode,
        success: exitCode == 0,
      ),
    );

    final commandResult = CommandResult(
      exitCode: exitCode,
      stdout: stdout.trimRight(),
      stderr: stderr.trimRight(),
      command: cmdString,
      duration: duration,
    );

    if (exitCode != 0) {
      throw GitCommandException(
        exitCode: exitCode,
        stderr: stderr.trimRight(),
        command: cmdString,
      );
    }

    return commandResult;
  }

  /// Run a git command, returning the result even on non-zero exit.
  /// Does not throw.
  Future<CommandResult> runAllowFailure(
    String command,
    List<String> args,
  ) async {
    final fullArgs = [command, ...args];
    final cmdString = 'git ${fullArgs.join(' ')}';
    final stopwatch = Stopwatch()..start();

    final result = await Process.run(
      'git',
      fullArgs,
      workingDirectory: workingDirectory,
    );

    stopwatch.stop();
    final duration = stopwatch.elapsed;
    final stdout = (result.stdout as String).trimRight();
    final stderr = (result.stderr as String).trimRight();

    log.add(
      CommandLogEntry(
        command: cmdString,
        timestamp: DateTime.now(),
        duration: duration,
        exitCode: result.exitCode,
        success: result.exitCode == 0,
      ),
    );

    return CommandResult(
      exitCode: result.exitCode,
      stdout: stdout,
      stderr: stderr,
      command: cmdString,
      duration: duration,
    );
  }
}
