import 'package:dtui/dtui.dart';

import 'context.dart';

class ContextStack {
  final List<Context> _stack = [];

  Context get top => _stack.last;

  bool get isEmpty => _stack.isEmpty;
  bool get isNotEmpty => _stack.isNotEmpty;
  int get length => _stack.length;

  void push(Context context) {
    _stack.add(context);
    context.onEnter();
  }

  Context pop() {
    final context = _stack.removeLast();
    context.onExit();
    return context;
  }

  void clear() {
    while (_stack.isNotEmpty) {
      pop();
    }
  }

  bool handleEvent(InputEvent event) {
    if (_stack.isEmpty) return false;
    return top.handleEvent(event);
  }
}
