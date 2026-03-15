class Keybinding {
  final String key;
  final String description;
  final String? context;
  final Future<void> Function() handler;

  const Keybinding({
    required this.key,
    required this.description,
    this.context,
    required this.handler,
  });
}
