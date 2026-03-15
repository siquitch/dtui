import '../git_command_runner.dart';

/// Commands for reading and writing git configuration.
class ConfigCommands {
  final GitCommandRunner _runner;

  ConfigCommands(this._runner);

  /// Get the value of a configuration key, or null if not set.
  Future<String?> get(String key) async {
    final result = await _runner.runAllowFailure('config', ['--get', key]);
    if (result.exitCode != 0 || result.stdout.isEmpty) return null;
    return result.stdout.trim();
  }

  /// Set a configuration key to a value.
  Future<void> set(String key, String value) async {
    await _runner.run('config', [key, value]);
  }

  /// List all configuration entries as a map.
  Future<Map<String, String>> listAll() async {
    final result = await _runner.runAllowFailure('config', ['--list']);
    if (result.exitCode != 0 || result.stdout.isEmpty) return {};

    final config = <String, String>{};
    for (final line in result.stdout.split('\n')) {
      if (line.trim().isEmpty) continue;
      final eqIndex = line.indexOf('=');
      if (eqIndex < 0) continue;
      final key = line.substring(0, eqIndex);
      final value = line.substring(eqIndex + 1);
      config[key] = value;
    }
    return config;
  }
}
