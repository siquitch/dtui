import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'config.dart';

class ConfigLoader {
  static String get _configDir {
    final home =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return p.join(home, '.config', 'gittui');
  }

  static String get _configPath => p.join(_configDir, 'config.yaml');

  static Future<AppConfig> load() async {
    final file = File(_configPath);
    if (!await file.exists()) {
      return const AppConfig();
    }

    try {
      final content = await file.readAsString();
      final yaml = loadYaml(content);
      if (yaml is! Map) return const AppConfig();

      return AppConfig(
        showCommandLog: yaml['show_command_log'] as bool? ?? false,
        sidebarWidth: yaml['sidebar_width'] as int? ?? 40,
        defaultBranch: yaml['default_branch'] as String?,
        customKeybindings: yaml['keybindings'] is Map
            ? (yaml['keybindings'] as Map).map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              )
            : const {},
      );
    } on Exception {
      return const AppConfig();
    }
  }

  static Future<void> save(AppConfig config) async {
    final dir = Directory(_configDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final buffer = StringBuffer();
    buffer.writeln('show_command_log: ${config.showCommandLog}');
    buffer.writeln('sidebar_width: ${config.sidebarWidth}');
    if (config.defaultBranch != null) {
      buffer.writeln('default_branch: ${config.defaultBranch}');
    }
    if (config.customKeybindings.isNotEmpty) {
      buffer.writeln('keybindings:');
      for (final entry in config.customKeybindings.entries) {
        buffer.writeln('  ${entry.key}: ${entry.value}');
      }
    }

    await File(_configPath).writeAsString(buffer.toString());
  }
}
