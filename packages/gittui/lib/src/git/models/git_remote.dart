/// Represents a git remote.
class GitRemote {
  final String name;
  final String fetchUrl;
  final String pushUrl;

  const GitRemote({
    required this.name,
    required this.fetchUrl,
    required this.pushUrl,
  });

  @override
  String toString() => 'GitRemote($name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitRemote && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
