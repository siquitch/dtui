import 'dart:io';

import 'package:args/args.dart';

import 'package:gittui/src/app/app.dart';

const String version = '0.1.0';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addFlag('version', abbr: 'v', negatable: false, help: 'Show version');

  final ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln('Usage: gittui [options] [path]');
    stderr.writeln(parser.usage);
    exit(1);
  }

  if (results.flag('help')) {
    stdout.writeln('gittui — a lazygit clone built in Dart');
    stdout.writeln('');
    stdout.writeln('Usage: gittui [options] [path]');
    stdout.writeln(parser.usage);
    return;
  }

  if (results.flag('version')) {
    stdout.writeln('gittui $version');
    return;
  }

  final path = results.rest.isNotEmpty ? results.rest.first : null;

  final app = DartGitApp();
  try {
    await app.run(path);
  } on Exception catch (e) {
    // Ensure terminal is restored even on error
    try {
      stdin.echoMode = true;
      stdin.lineMode = true;
      stdout.write('\x1B[?1049l'); // disable alternate screen
      stdout.write('\x1B[?25h'); // show cursor
    } catch (_) {}
    stderr.writeln('Error: $e');
    exit(1);
  }
}
