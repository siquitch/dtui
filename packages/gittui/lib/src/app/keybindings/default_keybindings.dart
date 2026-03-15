import 'package:dtui/dtui.dart';

import '../state/ui_state.dart';
import 'keybinding.dart';

class DefaultKeybindings {
  static List<Keybinding> build({
    required Future<void> Function() quit,
    required Future<void> Function() stageSelected,
    required Future<void> Function() stageAll,
    required Future<void> Function() discardSelected,
    required Future<void> Function() commitPrompt,
    required Future<void> Function() amendPrompt,
    required Future<void> Function() createBranchPrompt,
    required Future<void> Function() checkoutBranch,
    required Future<void> Function() deleteBranch,
    required Future<void> Function() push,
    required Future<void> Function() pull,
    required Future<void> Function() fetch,
    required Future<void> Function() stashChanges,
    required Future<void> Function() popStash,
    required void Function(SidebarPane) switchPane,
    required void Function() nextPane,
    required void Function() previousPane,
    required void Function() toggleCommandLog,
    required void Function() toggleHelp,
    required void Function() goBack,
  }) {
    return [
      // Global
      Keybinding(
        key: 'q',
        description: 'Quit',
        handler: quit,
      ),
      Keybinding(
        key: 'ctrl+c',
        description: 'Quit',
        handler: quit,
      ),
      Keybinding(
        key: keyTab,
        description: 'Next pane',
        handler: () async => nextPane(),
      ),
      Keybinding(
        key: 'shift+$keyTab',
        description: 'Previous pane',
        handler: () async => previousPane(),
      ),
      Keybinding(
        key: keyEscape,
        description: 'Go back / close popup',
        handler: () async => goBack(),
      ),
      Keybinding(
        key: 'x',
        description: 'Toggle command log',
        handler: () async => toggleCommandLog(),
      ),
      Keybinding(
        key: '?',
        description: 'Toggle help',
        handler: () async => toggleHelp(),
      ),

      // Pane navigation
      Keybinding(
        key: 'h',
        description: 'Previous pane',
        handler: () async => previousPane(),
      ),
      Keybinding(
        key: 'l',
        description: 'Next pane',
        handler: () async => nextPane(),
      ),

      // Pane shortcuts
      Keybinding(
        key: '1',
        description: 'Files pane',
        handler: () async => switchPane(SidebarPane.files),
      ),
      Keybinding(
        key: '2',
        description: 'Branches pane',
        handler: () async => switchPane(SidebarPane.branches),
      ),
      Keybinding(
        key: '3',
        description: 'Commits pane',
        handler: () async => switchPane(SidebarPane.commits),
      ),

      // File operations
      Keybinding(
        key: keySpace,
        description: 'Stage/unstage file',
        context: 'files',
        handler: stageSelected,
      ),
      Keybinding(
        key: 'a',
        description: 'Stage all',
        context: 'files',
        handler: stageAll,
      ),
      Keybinding(
        key: 'd',
        description: 'Discard changes',
        context: 'files',
        handler: discardSelected,
      ),

      // Commit
      Keybinding(
        key: 'c',
        description: 'Commit',
        handler: commitPrompt,
      ),
      Keybinding(
        key: 'A',
        description: 'Amend commit',
        handler: amendPrompt,
      ),

      // Branch operations
      Keybinding(
        key: 'n',
        description: 'New branch',
        context: 'branches',
        handler: createBranchPrompt,
      ),
      Keybinding(
        key: keySpace,
        description: 'Checkout branch',
        context: 'branches',
        handler: checkoutBranch,
      ),
      Keybinding(
        key: 'd',
        description: 'Delete branch',
        context: 'branches',
        handler: deleteBranch,
      ),

      // Remote
      Keybinding(
        key: 'p',
        description: 'Push',
        handler: push,
      ),
      Keybinding(
        key: 'P',
        description: 'Pull',
        handler: pull,
      ),
      Keybinding(
        key: 'f',
        description: 'Fetch',
        context: 'branches',
        handler: fetch,
      ),

      // Stash
      Keybinding(
        key: 's',
        description: 'Stash',
        handler: stashChanges,
      ),
    ];
  }
}
