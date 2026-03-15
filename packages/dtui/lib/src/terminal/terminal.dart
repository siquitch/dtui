import 'dart:async';
import 'dart:io';

import 'ansi.dart';
import 'input_parser.dart';

/// Wraps dart:io stdin/stdout with terminal management.
class Terminal {
  final InputParser _inputParser = InputParser();
  StreamSubscription<InputEvent>? _inputSubscription;
  Stream<InputEvent>? _eventStream;
  bool _echoWasEnabled = true;

  /// Initialize the terminal: enable raw mode, alternate screen,
  /// hide cursor, and enable mouse tracking.
  void init() {
    _echoWasEnabled = stdin.echoMode;
    stdin.echoMode = false;
    stdin.lineMode = false;
    stdout.write(Ansi.enableAlternateScreen());
    stdout.write(Ansi.hideCursor());
    stdout.write(Ansi.enableMouseTracking());
    stdout.write(Ansi.clearScreen());
  }

  /// Restore the terminal to its original state.
  Future<void> dispose() async {
    _inputSubscription?.cancel();
    _inputSubscription = null;
    stdout.write(Ansi.disableMouseTracking());
    stdout.write(Ansi.showCursor());
    stdout.write(Ansi.disableAlternateScreen());
    await flush();
    stdin.echoMode = _echoWasEnabled;
    stdin.lineMode = true;
  }

  /// Stream of parsed input events from stdin.
  Stream<InputEvent> get inputEvents {
    _eventStream ??= _inputParser
        .parse(stdin.asBroadcastStream())
        .asBroadcastStream();
    return _eventStream!;
  }

  /// Write raw string data to stdout.
  void write(String data) {
    stdout.write(data);
  }

  /// Get the current terminal dimensions as (width, height).
  (int, int) get size {
    return (stdout.terminalColumns, stdout.terminalLines);
  }

  /// Flush stdout.
  Future<void> flush() async {
    await stdout.flush();
  }
}
