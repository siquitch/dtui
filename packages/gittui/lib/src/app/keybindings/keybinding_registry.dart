import 'package:dtui/dtui.dart';

import 'keybinding.dart';

class KeybindingRegistry {
  final List<Keybinding> _bindings = [];

  void register(Keybinding binding) {
    _bindings.add(binding);
  }

  void registerAll(List<Keybinding> bindings) {
    _bindings.addAll(bindings);
  }

  Keybinding? resolve(InputEvent event, String? contextName) {
    if (event is! KeyEvent) return null;
    final keyStr = _normalizeKey(event);

    // Context-specific bindings first
    if (contextName != null) {
      for (final b in _bindings) {
        if (b.context == contextName && b.key == keyStr) return b;
      }
    }

    // Global bindings
    for (final b in _bindings) {
      if (b.context == null && b.key == keyStr) return b;
    }

    return null;
  }

  List<Keybinding> getBindingsForContext(String? contextName) {
    return _bindings.where((b) => b.context == contextName).toList();
  }

  List<Keybinding> get allBindings => List.unmodifiable(_bindings);

  String _normalizeKey(KeyEvent event) {
    final parts = <String>[];
    if (event.ctrl) parts.add('ctrl');
    if (event.alt) parts.add('alt');
    if (event.shift && event.key.length > 1) parts.add('shift');
    parts.add(event.key);
    return parts.join('+');
  }
}
