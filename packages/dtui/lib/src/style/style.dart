import 'color.dart';

/// Text styling for terminal output.
class Style {
  final Color? foreground;
  final Color? background;
  final bool bold;
  final bool dim;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool inverse;

  const Style({
    this.foreground,
    this.background,
    this.bold = false,
    this.dim = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.inverse = false,
  });

  /// A style with no attributes set.
  static const Style none = Style();

  /// Returns the ANSI escape prefix to enable this style.
  String toAnsiPrefix() {
    final codes = <String>[];

    if (bold) codes.add('1');
    if (dim) codes.add('2');
    if (italic) codes.add('3');
    if (underline) codes.add('4');
    if (inverse) codes.add('7');
    if (strikethrough) codes.add('9');

    if (foreground != null) {
      codes.add(foreground!.toForegroundCode());
    }
    if (background != null) {
      codes.add(background!.toBackgroundCode());
    }

    if (codes.isEmpty) return '';
    return '\x1B[${codes.join(';')}m';
  }

  /// Returns the ANSI escape suffix to reset styling.
  String toAnsiSuffix() {
    if (foreground == null &&
        background == null &&
        !bold &&
        !dim &&
        !italic &&
        !underline &&
        !strikethrough &&
        !inverse) {
      return '';
    }
    return '\x1B[0m';
  }

  /// Combine another style on top of this one. Non-null fields in [other]
  /// override fields in this style. Boolean attributes are OR'd together
  /// (once enabled, they stay enabled). Use [copyWith] to replace attributes.
  Style merge(Style other) {
    return Style(
      foreground: other.foreground ?? foreground,
      background: other.background ?? background,
      bold: other.bold || bold,
      dim: other.dim || dim,
      italic: other.italic || italic,
      underline: other.underline || underline,
      strikethrough: other.strikethrough || strikethrough,
      inverse: other.inverse || inverse,
    );
  }

  /// Create a copy with selected fields replaced.
  Style copyWith({
    Color? foreground,
    Color? background,
    bool? bold,
    bool? dim,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    bool? inverse,
  }) {
    return Style(
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
      bold: bold ?? this.bold,
      dim: dim ?? this.dim,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      inverse: inverse ?? this.inverse,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Style &&
        other.foreground == foreground &&
        other.background == background &&
        other.bold == bold &&
        other.dim == dim &&
        other.italic == italic &&
        other.underline == underline &&
        other.strikethrough == strikethrough &&
        other.inverse == inverse;
  }

  @override
  int get hashCode => Object.hash(
        foreground,
        background,
        bold,
        dim,
        italic,
        underline,
        strikethrough,
        inverse,
      );
}
