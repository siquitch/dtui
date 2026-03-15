/// Represents a reflog entry.
class GitLogEntry {
  final String hash;
  final String shortHash;
  final String action;
  final String message;
  final DateTime date;

  const GitLogEntry({
    required this.hash,
    required this.shortHash,
    required this.action,
    required this.message,
    required this.date,
  });

  @override
  String toString() => 'GitLogEntry($shortHash $action: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitLogEntry && other.hash == hash;
  }

  @override
  int get hashCode => hash.hashCode;
}
