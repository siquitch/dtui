/// Terminal color supporting 16 ANSI colors, 256-color, and 24-bit truecolor.
class Color {
  /// The type of color encoding.
  final _ColorType _type;

  /// For [_ColorType.ansi16], the ANSI color code (0-15).
  /// For [_ColorType.ansi256], the 256-color index (0-255).
  final int _index;

  /// RGB components for truecolor.
  final int _r;
  final int _g;
  final int _b;

  const Color._ansi16(int index)
      : _type = _ColorType.ansi16,
        _index = index,
        _r = 0,
        _g = 0,
        _b = 0;

  const Color._ansi256(int index)
      : _type = _ColorType.ansi256,
        _index = index,
        _r = 0,
        _g = 0,
        _b = 0;

  const Color._rgb(int r, int g, int b)
      : _type = _ColorType.rgb,
        _index = 0,
        _r = r,
        _g = g,
        _b = b;

  const Color._reset()
      : _type = _ColorType.reset,
        _index = 0,
        _r = 0,
        _g = 0,
        _b = 0;

  /// A sentinel value indicating color reset.
  static const Color reset = Color._reset();

  // Standard 16 ANSI colors
  static const Color black = Color._ansi16(0);
  static const Color red = Color._ansi16(1);
  static const Color green = Color._ansi16(2);
  static const Color yellow = Color._ansi16(3);
  static const Color blue = Color._ansi16(4);
  static const Color magenta = Color._ansi16(5);
  static const Color cyan = Color._ansi16(6);
  static const Color white = Color._ansi16(7);
  static const Color brightBlack = Color._ansi16(8);
  static const Color brightRed = Color._ansi16(9);
  static const Color brightGreen = Color._ansi16(10);
  static const Color brightYellow = Color._ansi16(11);
  static const Color brightBlue = Color._ansi16(12);
  static const Color brightMagenta = Color._ansi16(13);
  static const Color brightCyan = Color._ansi16(14);
  static const Color brightWhite = Color._ansi16(15);

  /// Create a color from a 256-color index.
  factory Color.ansi(int index) {
    assert(index >= 0 && index <= 255);
    // Map indices 0-15 to the named ANSI 16 constants' internal representation.
    if (index < 16) {
      return Color._ansi16(index);
    }
    return Color._ansi256(index);
  }

  /// Create a 24-bit truecolor.
  factory Color.rgb(int r, int g, int b) {
    assert(r >= 0 && r <= 255);
    assert(g >= 0 && g <= 255);
    assert(b >= 0 && b <= 255);
    return Color._rgb(r, g, b);
  }

  /// Returns the ANSI escape sequence for using this color as foreground.
  String toForegroundCode() =>
      _toAnsiCode(fgBase: 30, fgBright: 90, fg256: 38, fgReset: 39);

  /// Returns the ANSI escape sequence for using this color as background.
  String toBackgroundCode() =>
      _toAnsiCode(fgBase: 40, fgBright: 100, fg256: 48, fgReset: 49);

  String _toAnsiCode({
    required int fgBase,
    required int fgBright,
    required int fg256,
    required int fgReset,
  }) {
    switch (_type) {
      case _ColorType.reset:
        return '$fgReset';
      case _ColorType.ansi16:
        if (_index < 8) {
          return '${fgBase + _index}';
        }
        return '${fgBright + _index - 8}';
      case _ColorType.ansi256:
        return '$fg256;5;$_index';
      case _ColorType.rgb:
        return '$fg256;2;$_r;$_g;$_b';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Color &&
        other._type == _type &&
        other._index == _index &&
        other._r == _r &&
        other._g == _g &&
        other._b == _b;
  }

  @override
  int get hashCode => Object.hash(_type, _index, _r, _g, _b);
}

enum _ColorType { ansi16, ansi256, rgb, reset }
