/// Represents a single git commit.
class GitCommit {
  final String hash;
  final String shortHash;
  final String subject;
  final String body;
  final String authorName;
  final String authorEmail;
  final DateTime authorDate;
  final List<String> parentHashes;
  final List<String> tags;
  final List<String> refs;

  const GitCommit({
    required this.hash,
    required this.shortHash,
    required this.subject,
    this.body = '',
    required this.authorName,
    required this.authorEmail,
    required this.authorDate,
    this.parentHashes = const [],
    this.tags = const [],
    this.refs = const [],
  });

  /// A merge commit has more than one parent.
  bool get isMergeCommit => parentHashes.length > 1;

  @override
  String toString() => 'GitCommit($shortHash $subject)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitCommit && other.hash == hash;
  }

  @override
  int get hashCode => hash.hashCode;
}
