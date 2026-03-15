/// The type of a line in a unified diff.
enum DiffLineType {
  context,
  added,
  removed,
  header,
  noNewline,
}

/// A single line in a diff hunk.
class DiffLine {
  final DiffLineType type;
  final String content;
  final int? oldLineNumber;
  final int? newLineNumber;

  const DiffLine({
    required this.type,
    required this.content,
    this.oldLineNumber,
    this.newLineNumber,
  });

  @override
  String toString() {
    final prefix = switch (type) {
      DiffLineType.added => '+',
      DiffLineType.removed => '-',
      DiffLineType.header => '@@',
      DiffLineType.noNewline => '\\',
      DiffLineType.context => ' ',
    };
    return '$prefix $content';
  }
}

/// A hunk within a diff, containing a contiguous set of changes.
class DiffHunk {
  final String header;
  final int oldStart;
  final int oldCount;
  final int newStart;
  final int newCount;
  final List<DiffLine> lines;

  const DiffHunk({
    required this.header,
    required this.oldStart,
    required this.oldCount,
    required this.newStart,
    required this.newCount,
    required this.lines,
  });

  @override
  String toString() => 'DiffHunk(@@ -$oldStart,$oldCount +$newStart,$newCount @@)';
}

/// Represents a parsed unified diff for a single file.
class GitDiff {
  final String? oldFile;
  final String? newFile;
  final bool isBinary;
  final bool isNew;
  final bool isDeleted;
  final bool isRenamed;
  final List<DiffHunk> hunks;

  const GitDiff({
    this.oldFile,
    this.newFile,
    this.isBinary = false,
    this.isNew = false,
    this.isDeleted = false,
    this.isRenamed = false,
    this.hunks = const [],
  });

  /// Parse a single unified diff output into a [GitDiff].
  static GitDiff parse(String diffOutput) {
    final results = parseMulti(diffOutput);
    if (results.isEmpty) {
      return const GitDiff();
    }
    return results.first;
  }

  /// Parse output that may contain multiple diffs (e.g. from `git diff`).
  static List<GitDiff> parseMulti(String output) {
    if (output.trim().isEmpty) return [];

    final diffs = <GitDiff>[];
    final lines = output.split('\n');

    int i = 0;
    while (i < lines.length) {
      // Look for the start of a diff: "diff --git a/... b/..."
      if (!lines[i].startsWith('diff --git ')) {
        i++;
        continue;
      }

      String? oldFile;
      String? newFile;
      var isBinary = false;
      var isNew = false;
      var isDeleted = false;
      var isRenamed = false;
      final hunks = <DiffHunk>[];

      // Parse the "diff --git a/foo b/bar" line
      final diffLine = lines[i];
      final diffMatch = RegExp(r'^diff --git a/(.*) b/(.*)$').firstMatch(diffLine);
      if (diffMatch != null) {
        oldFile = diffMatch.group(1);
        newFile = diffMatch.group(2);
      }

      i++;

      // Parse header lines until we hit a hunk or the next diff
      while (i < lines.length && !lines[i].startsWith('diff --git ')) {
        final line = lines[i];

        if (line.startsWith('new file mode')) {
          isNew = true;
          i++;
        } else if (line.startsWith('deleted file mode')) {
          isDeleted = true;
          i++;
        } else if (line.startsWith('similarity index') ||
            line.startsWith('rename from')) {
          isRenamed = true;
          i++;
        } else if (line.startsWith('rename to')) {
          final match = RegExp(r'^rename to (.*)$').firstMatch(line);
          if (match != null) {
            newFile = match.group(1);
          }
          i++;
        } else if (line.startsWith('Binary files')) {
          isBinary = true;
          i++;
        } else if (line.startsWith('--- ')) {
          final path = line.substring(4);
          if (path != '/dev/null') {
            oldFile = path.startsWith('a/') ? path.substring(2) : path;
          }
          i++;
        } else if (line.startsWith('+++ ')) {
          final path = line.substring(4);
          if (path != '/dev/null') {
            newFile = path.startsWith('b/') ? path.substring(2) : path;
          }
          i++;
        } else if (line.startsWith('@@ ')) {
          // Parse hunk header
          final hunkResult = _parseHunk(lines, i);
          if (hunkResult != null) {
            hunks.add(hunkResult.hunk);
            i = hunkResult.nextIndex;
          } else {
            i++;
          }
        } else {
          // Other header lines (index, old mode, new mode, etc.)
          i++;
        }
      }

      diffs.add(GitDiff(
        oldFile: oldFile,
        newFile: newFile,
        isBinary: isBinary,
        isNew: isNew,
        isDeleted: isDeleted,
        isRenamed: isRenamed,
        hunks: hunks,
      ));
    }

    return diffs;
  }

  static _HunkParseResult? _parseHunk(List<String> lines, int startIndex) {
    final headerLine = lines[startIndex];
    final match = RegExp(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@(.*)$')
        .firstMatch(headerLine);
    if (match == null) return null;

    final oldStart = int.parse(match.group(1)!);
    final oldCount = int.tryParse(match.group(2) ?? '1') ?? 1;
    final newStart = int.parse(match.group(3)!);
    final newCount = int.tryParse(match.group(4) ?? '1') ?? 1;
    final headerSuffix = match.group(5) ?? '';
    final header = '@@ -$oldStart,$oldCount +$newStart,$newCount @@$headerSuffix';

    final diffLines = <DiffLine>[];
    var oldLine = oldStart;
    var newLine = newStart;

    int i = startIndex + 1;
    while (i < lines.length) {
      final line = lines[i];

      // Stop at next hunk, next diff, or end
      if (line.startsWith('diff --git ') || line.startsWith('@@ ')) {
        break;
      }

      if (line.startsWith('+')) {
        diffLines.add(DiffLine(
          type: DiffLineType.added,
          content: line.substring(1),
          newLineNumber: newLine,
        ));
        newLine++;
      } else if (line.startsWith('-')) {
        diffLines.add(DiffLine(
          type: DiffLineType.removed,
          content: line.substring(1),
          oldLineNumber: oldLine,
        ));
        oldLine++;
      } else if (line.startsWith(r'\ No newline at end of file') ||
          line.startsWith(r'\')) {
        diffLines.add(DiffLine(
          type: DiffLineType.noNewline,
          content: line,
        ));
      } else {
        // Context line (starts with space or is empty)
        final content = line.isNotEmpty ? line.substring(1) : '';
        diffLines.add(DiffLine(
          type: DiffLineType.context,
          content: content,
          oldLineNumber: oldLine,
          newLineNumber: newLine,
        ));
        oldLine++;
        newLine++;
      }
      i++;
    }

    return _HunkParseResult(
      hunk: DiffHunk(
        header: header,
        oldStart: oldStart,
        oldCount: oldCount,
        newStart: newStart,
        newCount: newCount,
        lines: diffLines,
      ),
      nextIndex: i,
    );
  }

  @override
  String toString() => 'GitDiff(${oldFile ?? newFile})';
}

class _HunkParseResult {
  final DiffHunk hunk;
  final int nextIndex;

  const _HunkParseResult({required this.hunk, required this.nextIndex});
}
