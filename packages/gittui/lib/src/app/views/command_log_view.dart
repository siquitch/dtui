import 'package:dtui/dtui.dart';

import '../../git/git_command_runner.dart';

class CommandLogView extends Widget {
  final List<CommandLogEntry> entries;
  int scrollOffset = 0;

  CommandLogView({required this.entries});

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0) return;

    if (entries.isEmpty) {
      canvas.drawText(
        area.x + 1,
        area.y,
        'No commands executed yet',
        const Style(dim: true),
      );
      return;
    }

    // Show most recent entries (reverse chronological)
    final startIndex = entries.length - 1 - scrollOffset;
    for (var i = 0; i < area.height; i++) {
      final entryIndex = startIndex - i;
      if (entryIndex < 0) break;

      final entry = entries[entryIndex];
      final style = entry.success
          ? const Style(foreground: Color.green)
          : const Style(foreground: Color.red);

      final durationMs = entry.duration.inMilliseconds;
      final text = '${entry.success ? "✓" : "✗"} ${entry.command} (${durationMs}ms)';

      for (var j = 0; j < text.length && j < area.width; j++) {
        canvas.drawChar(area.x + j, area.y + i, text[j], style);
      }
    }
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return constraints.constrain(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  bool handleEvent(InputEvent event) => false;
}
