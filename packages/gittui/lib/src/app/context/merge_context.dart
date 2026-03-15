import 'package:dtui/dtui.dart';

import '../../git/models/git_file.dart';
import 'context.dart';

class MergeContext extends Context {
  List<GitFile> conflictedFiles;
  int selectedIndex = 0;

  MergeContext({this.conflictedFiles = const []});

  @override
  String get name => 'merge';

  @override
  bool handleEvent(InputEvent event) {
    if (event is! KeyEvent || conflictedFiles.isEmpty) return false;
    switch (event.key) {
      case keyDown:
      case 'j':
        selectedIndex = (selectedIndex + 1).clamp(0, conflictedFiles.length - 1);
        return true;
      case keyUp:
      case 'k':
        selectedIndex = (selectedIndex - 1).clamp(0, conflictedFiles.length - 1);
        return true;
      default:
        return false;
    }
  }
}
