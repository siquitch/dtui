/// Represents a git branch (local or remote).
class GitBranch {
  final String name;
  final String? remoteName;
  final String? upstream;
  final String? commitHash;
  final String? commitSubject;
  final bool isHead;
  final bool isRemote;
  final int? ahead;
  final int? behind;

  const GitBranch({
    required this.name,
    this.remoteName,
    this.upstream,
    this.commitHash,
    this.commitSubject,
    this.isHead = false,
    this.isRemote = false,
    this.ahead,
    this.behind,
  });

  /// Display name: for remote branches strips the remote prefix.
  String get displayName {
    if (isRemote && remoteName != null && name.startsWith('$remoteName/')) {
      return name.substring(remoteName!.length + 1);
    }
    return name;
  }

  @override
  String toString() => 'GitBranch($name${isHead ? " *" : ""})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitBranch &&
        other.name == name &&
        other.isRemote == isRemote;
  }

  @override
  int get hashCode => Object.hash(name, isRemote);
}
