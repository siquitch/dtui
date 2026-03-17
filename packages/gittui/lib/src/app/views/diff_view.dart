import 'package:dtui/dtui.dart';

import '../../git/models/git_diff.dart';

class DiffView extends Widget {
  final GitDiff? diff;
  final int scrollOffset;
  final int selectedLine;

  DiffView({this.diff, this.scrollOffset = 0, this.selectedLine = 0});

  @override
  void render(Canvas canvas, Rect area) {
    if (area.width <= 0 || area.height <= 0) return;

    if (diff == null) {
      canvas.drawText(
        area.x + 1,
        area.y + 1,
        'No diff to display',
        const Style(dim: true),
      );
      return;
    }

    // Build flat list of renderable lines
    final lines = <_DiffDisplayLine>[];

    // File header
    final fileName = diff!.newFile ?? diff!.oldFile ?? 'unknown';
    lines.add(
      _DiffDisplayLine(
        text: '--- ${diff!.oldFile ?? "/dev/null"}',
        style: const Style(bold: true),
      ),
    );
    lines.add(
      _DiffDisplayLine(
        text: '+++ ${diff!.newFile ?? "/dev/null"}',
        style: const Style(bold: true),
      ),
    );

    if (diff!.isBinary) {
      lines.add(
        _DiffDisplayLine(
          text: 'Binary file $fileName',
          style: const Style(dim: true),
        ),
      );
    } else {
      for (final hunk in diff!.hunks) {
        lines.add(
          _DiffDisplayLine(
            text: hunk.header,
            style: const Style(foreground: Color.cyan),
          ),
        );
        for (final line in hunk.lines) {
          final style = switch (line.type) {
            DiffLineType.added => const Style(foreground: Color.green),
            DiffLineType.removed => const Style(foreground: Color.red),
            DiffLineType.header => const Style(foreground: Color.cyan),
            DiffLineType.noNewline => const Style(dim: true),
            DiffLineType.context => Style.none,
          };
          final prefix = switch (line.type) {
            DiffLineType.added => '+',
            DiffLineType.removed => '-',
            _ => ' ',
          };
          lines.add(
            _DiffDisplayLine(
              text: '$prefix${line.content}',
              style: style,
            ),
          );
        }
      }
    }

    // Render visible lines
    var renderOffset = scrollOffset;
    if (selectedLine >= renderOffset + area.height) {
      renderOffset = selectedLine - area.height + 1;
    }
    if (selectedLine < renderOffset) {
      renderOffset = selectedLine;
    }

    for (var i = 0; i < area.height; i++) {
      final lineIndex = renderOffset + i;
      if (lineIndex >= lines.length) break;

      final line = lines[lineIndex];
      var style = line.style;
      if (lineIndex == selectedLine) {
        style = style.merge(const Style(inverse: true));
      }

      // Clear line
      for (var x = area.x; x < area.right; x++) {
        canvas.drawChar(
          x,
          area.y + i,
          ' ',
          lineIndex == selectedLine ? style : Style.none,
        );
      }

      // Draw text, truncated
      final text = line.text;
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

class _DiffDisplayLine {
  final String text;
  final Style style;
  const _DiffDisplayLine({required this.text, required this.style});
}
