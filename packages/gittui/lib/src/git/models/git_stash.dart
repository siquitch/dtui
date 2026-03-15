/// Represents an entry in the git stash.
class GitStash {
  final int index;
  final String message;
  final String hash;
  final String branchName;

  const GitStash({
    required this.index,
    required this.message,
    required this.hash,
    required this.branchName,
  });

  @override
  String toString() => 'GitStash(stash@{$index}: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitStash && other.index == index && other.hash == hash;
  }

  @override
  int get hashCode => Object.hash(index, hash);
}
