/// Static methods for generating ANSI escape sequences.
class Ansi {
  Ansi._();

  static const String _csi = '\x1B[';
  static const String _esc = '\x1B';

  /// Move cursor to position (1-based coordinates for ANSI).
  static String moveTo(int x, int y) => '$_csi${y + 1};${x + 1}H';

  /// Move cursor up by [n] lines.
  static String moveUp(int n) => '$_csi${n}A';

  /// Move cursor down by [n] lines.
  static String moveDown(int n) => '$_csi${n}B';

  /// Move cursor right by [n] columns.
  static String moveRight(int n) => '$_csi${n}C';

  /// Move cursor left by [n] columns.
  static String moveLeft(int n) => '$_csi${n}D';

  /// Move cursor to the beginning of line [n] lines down.
  static String moveToNextLine(int n) => '$_csi${n}E';

  /// Move cursor to the beginning of line [n] lines up.
  static String moveToPreviousLine(int n) => '$_csi${n}F';

  /// Move cursor to column [x] (0-based).
  static String moveToColumn(int x) => '$_csi${x + 1}G';

  /// Clear the entire screen.
  static String clearScreen() => '${_csi}2J';

  /// Clear from cursor to end of screen.
  static String clearToEndOfScreen() => '${_csi}0J';

  /// Clear the current line.
  static String clearLine() => '${_csi}2K';

  /// Clear from cursor to end of line.
  static String clearToEndOfLine() => '${_csi}0K';

  /// Hide the cursor.
  static String hideCursor() => '$_csi?25l';

  /// Show the cursor.
  static String showCursor() => '$_csi?25h';

  /// Enable raw mode escape sequence (DECSET for application keypad).
  static String enableRawMode() => '$_csi?1h';

  /// Disable raw mode escape sequence.
  static String disableRawMode() => '$_csi?1l';

  /// Switch to the alternate screen buffer.
  static String enableAlternateScreen() => '$_csi?1049h';

  /// Switch back to the normal screen buffer.
  static String disableAlternateScreen() => '$_csi?1049l';

  /// Enable SGR mouse tracking (button events + SGR encoding).
  static String enableMouseTracking() => '$_csi?1000h$_csi?1002h$_csi?1006h';

  /// Disable SGR mouse tracking.
  static String disableMouseTracking() => '$_csi?1006l$_csi?1002l$_csi?1000l';

  /// Set the terminal window title.
  static String setTitle(String title) => '$_esc]0;$title$_esc\\';

  /// Reset all text attributes.
  static String resetStyle() => '${_csi}0m';
}
