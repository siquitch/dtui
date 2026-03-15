import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class CustomCommand {
  final String name;
  final String command;
  final String? description;
  final String? key;

  const CustomCommand({
    required this.name,
    required this.command,
    this.description,
    this.key,
  });
}

class CustomCommandLoader {
  static Future<List<CustomCommand>> load() async {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    final path = p.join(home, '.config', 'gittui', 'custom_commands.yaml');
    final file = File(path);

    if (!await file.exists()) return [];

    try {
      final content = await file.readAsString();
      final yaml = loadYaml(content);
      if (yaml is! YamlList) return [];

      return yaml.map((item) {
        if (item is! Map) return null;
        return CustomCommand(
          name: item['name']?.toString() ?? '',
          command: item['command']?.toString() ?? '',
          description: item['description']?.toString(),
          key: item['key']?.toString(),
        );
      }).whereType<CustomCommand>().toList();
    } on Exception {
      return [];
    }
  }
}
