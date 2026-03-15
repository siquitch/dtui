import 'dart:async';
import 'dart:io';

import 'layout/rect.dart';
import 'rendering/buffer.dart';
import 'rendering/canvas.dart';
import 'rendering/diff_renderer.dart';
import 'terminal/input_parser.dart';
import 'terminal/terminal.dart';
import 'widgets/widget.dart';

/// The main TUI application runner.
class DTuiApp {
  final Widget Function() buildRoot;
  final FutureOr<void> Function(InputEvent)? onEvent;
  final Terminal terminal;
  final DiffRenderer _renderer = DiffRenderer();

  Buffer? _previousBuffer;
  bool _needsRender = true;
  bool _running = false;
  Completer<void>? _exitCompleter;
  StreamSubscription<InputEvent>? _inputSub;
  StreamSubscription<ProcessSignal>? _sigwinchSub;

  DTuiApp({required this.buildRoot, this.onEvent, Terminal? terminal})
      : terminal = terminal ?? Terminal();

  /// Request a re-render on the next cycle.
  void requestRender() {
    _needsRender = true;
  }

  /// Shut down the application cleanly.
  void exit() {
    _running = false;
    _exitCompleter?.complete();
  }

  /// Run the main event loop.
  Future<void> run() async {
    _exitCompleter = Completer<void>();
    _running = true;

    terminal.init();
    try {
      // Initial full render
      await _renderFrame(fullRender: true);

      // Listen for input events
      _inputSub = terminal.inputEvents.listen(
        (event) async {
          if (!_running) return;

          // Handle resize events
          if (event is ResizeEvent) {
            _needsRender = true;
            await _renderFrame(fullRender: true);
            return;
          }

          // Dispatch to event handler or root widget
          if (onEvent != null) {
            await onEvent!(event);
          } else {
            final root = buildRoot();
            root.handleEvent(event);
          }
          _needsRender = true;
          await _renderFrame();
        },
        onError: (_) {},
      );

      // Listen for SIGWINCH (terminal resize) on supported platforms
      try {
        _sigwinchSub = ProcessSignal.sigwinch.watch().listen((_) async {
          if (!_running) return;
          _needsRender = true;
          await _renderFrame(fullRender: true);
        }, onError: (_) {});
      } catch (_) {
        // SIGWINCH not available on all platforms
      }

      // Wait until exit is called
      await _exitCompleter!.future;
    } finally {
      await _inputSub?.cancel();
      await _sigwinchSub?.cancel();
      terminal.dispose();
    }
  }

  Future<void> _renderFrame({bool fullRender = false}) async {
    if (!_needsRender) return;
    _needsRender = false;

    final (width, height) = terminal.size;
    if (width <= 0 || height <= 0) return;

    final buffer = Buffer(width, height);
    final canvas = Canvas(buffer, Rect(0, 0, width, height));
    final area = Rect(0, 0, width, height);

    final root = buildRoot();
    root.render(canvas, area);

    String output;
    if (fullRender || _previousBuffer == null) {
      output = _renderer.renderFull(buffer);
    } else {
      output = _renderer.render(_previousBuffer!, buffer);
    }

    if (output.isNotEmpty) {
      terminal.write(output);
      await terminal.flush();
    }

    _previousBuffer = buffer;
  }
}
