import 'package:dtui/dtui.dart';

abstract class Context {
  String get name;

  bool handleEvent(InputEvent event);

  void onEnter() {}
  void onExit() {}
}
