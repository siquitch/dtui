import 'dart:io';

import 'package:dtui/dtui.dart';

import '../git/git_command_runner.dart';
import '../git/git_repository.dart';
import 'context/context_stack.dart';
import 'context/diff_context.dart';
import 'controllers/branches_controller.dart';
import 'controllers/commits_controller.dart';
import 'controllers/files_controller.dart';
import 'controllers/merge_controller.dart';
import 'controllers/rebase_controller.dart';
import 'controllers/stash_controller.dart';
import 'controllers/status_controller.dart';
import 'keybindings/default_keybindings.dart';
import 'keybindings/keybinding_registry.dart';
import 'refresh.dart';
import 'state/app_state.dart';
import 'state/ui_state.dart';
import 'views/main_layout.dart';
import 'views/popup_views/branch_create_popup.dart';
import 'views/popup_views/commit_message_popup.dart';
import 'views/popup_views/confirmation_popup.dart';

class GittuiApp {
  late final GitRepository _repo;
  late final TuiApp _tuiApp;
  late final KeybindingRegistry _keybindingRegistry;
  late final ContextStack _contextStack;
  late final RefreshCoordinator _refreshCoordinator;

  // Controllers
  late final FilesController _filesController;
  late final BranchesController _branchesController;
  late final CommitsController _commitsController;
  late final StashController _stashController;
  late final StatusController _statusController;
  // Used in M7/M8 milestones for merge/rebase workflows
  // ignore: unused_field
  late final MergeController _mergeController;
  // ignore: unused_field
  late final RebaseController _rebaseController;

  // Diff context for right panel
  final DiffViewContext _diffContext = DiffViewContext();

  AppState _state = const AppState();
  Widget? _activePopup;

  AppState _getState() => _state;
  void _setState(AppState newState) {
    _state = newState;
    _tuiApp.requestRender();
  }

  Future<void> run(String? path) async {
    final repoPath = path ?? Directory.current.path;

    _repo = await GitRepository.open(repoPath);

    _filesController = FilesController(
      repo: _repo,
      getState: _getState,
      setState: _setState,
    );
    _branchesController = BranchesController(
      repo: _repo,
      getState: _getState,
      setState: _setState,
    );
    _commitsController = CommitsController(
      repo: _repo,
      getState: _getState,
      setState: _setState,
    );
    _stashController = StashController(
      repo: _repo,
      getState: _getState,
      setState: _setState,
    );
    _statusController = StatusController(
      repo: _repo,
      getState: _getState,
      setState: _setState,
    );
    _mergeController = MergeController(
      repo: _repo,
      getState: _getState,
      setState: _setState,
    );
    _rebaseController = RebaseController(
      repo: _repo,
      getState: _getState,
      setState: _setState,
    );

    _refreshCoordinator = RefreshCoordinator(
      filesController: _filesController,
      branchesController: _branchesController,
      commitsController: _commitsController,
      stashController: _stashController,
      statusController: _statusController,
    );

    _contextStack = ContextStack();
    _keybindingRegistry = KeybindingRegistry();

    _setupKeybindings();

    _tuiApp = TuiApp(buildRoot: _buildRoot, onEvent: _handleInput);

    // Initial data load
    await _refreshCoordinator.refreshAll();
    await _filesController.loadDiffForSelected();

    _state = _state.copyWith(
      git: _state.git.copyWith(repoRoot: repoPath),
    );

    await _tuiApp.run();
  }

  Widget _buildRoot() {
    // If there's an active popup, render it on top
    if (_activePopup != null) {
      return _PopupOverlay(
        background: _buildMainLayout(),
        popup: _activePopup!,
      );
    }
    return _buildMainLayout();
  }

  Widget _buildMainLayout() {
    return MainLayout(
      appState: _state,
      selectedFileIndex: _filesController.selectedIndex,
      selectedBranchIndex: _branchesController.selectedIndex,
      selectedCommitIndex: _commitsController.selectedIndex,
      selectedStashIndex: _stashController.selectedIndex,
      diffScrollOffset: _diffContext.scrollOffset,
      diffSelectedLine: _diffContext.selectedLine,
      commandLog: _repo.runner.log,
    );
  }

  void _setupKeybindings() {
    final bindings = DefaultKeybindings.build(
      quit: () async => _tuiApp.exit(),
      stageSelected: () async {
        await _filesController.toggleStageSelected();
        _diffContext.reset();
        await _filesController.loadDiffForSelected();
        await _refreshCoordinator.refresh({RefreshScope.status});
      },
      stageAll: () async {
        await _filesController.stageAll();
        _diffContext.reset();
        await _filesController.loadDiffForSelected();
        await _refreshCoordinator.refresh({RefreshScope.status});
      },
      discardSelected: () async {
        _showConfirmation(
          'Discard Changes',
          'Are you sure you want to discard changes to ${_filesController.selectedFile?.path ?? "this file"}?',
          () async {
            await _filesController.discardSelected();
            _diffContext.reset();
            await _filesController.loadDiffForSelected();
          },
        );
      },
      commitPrompt: () async {
        _showCommitPopup(amend: false);
      },
      amendPrompt: () async {
        _showCommitPopup(amend: true);
      },
      createBranchPrompt: () async {
        _showBranchCreatePopup();
      },
      checkoutBranch: () async {
        await _branchesController.checkoutSelected();
        await _refreshCoordinator.refreshAll();
      },
      deleteBranch: () async {
        final branch = _branchesController.selectedBranch;
        if (branch == null) return;
        _showConfirmation(
          'Delete Branch',
          'Delete branch "${branch.name}"?',
          () async {
            await _branchesController.deleteSelected();
          },
        );
      },
      push: () async {
        _setStatus('Pushing...');
        try {
          await _repo.remotes.push();
          _setStatus('Push complete');
        } on GitCommandException catch (e) {
          _setError('Push failed: ${e.stderr}');
        }
      },
      pull: () async {
        _setStatus('Pulling...');
        try {
          await _repo.remotes.pull();
          _setStatus('Pull complete');
          await _refreshCoordinator.refreshAll();
        } on GitCommandException catch (e) {
          _setError('Pull failed: ${e.stderr}');
        }
      },
      fetch: () async {
        _setStatus('Fetching...');
        try {
          await _repo.remotes.fetch();
          _setStatus('Fetch complete');
          await _branchesController.refresh();
        } on GitCommandException catch (e) {
          _setError('Fetch failed: ${e.stderr}');
        }
      },
      stashChanges: () async {
        await _stashController.stashChanges();
        await _refreshCoordinator.refresh({RefreshScope.files, RefreshScope.stash});
      },
      popStash: () async {
        await _stashController.popSelected();
        await _refreshCoordinator.refresh({RefreshScope.files, RefreshScope.stash});
      },
      switchTab: (tab) {
        _setState(_state.copyWith(ui: _state.ui.copyWith(activeTab: tab)));
      },
      nextTab: () {
        final tabs = SidebarTab.values;
        final current = tabs.indexOf(_state.ui.activeTab);
        final next = (current + 1) % tabs.length;
        _setState(_state.copyWith(
            ui: _state.ui.copyWith(activeTab: tabs[next])));
      },
      previousTab: () {
        final tabs = SidebarTab.values;
        final current = tabs.indexOf(_state.ui.activeTab);
        final prev = (current - 1 + tabs.length) % tabs.length;
        _setState(_state.copyWith(
            ui: _state.ui.copyWith(activeTab: tabs[prev])));
      },
      toggleCommandLog: () {
        _setState(_state.copyWith(
            ui: _state.ui.copyWith(
                showCommandLog: !_state.ui.showCommandLog)));
      },
      toggleHelp: () {
        _setState(_state.copyWith(
            ui: _state.ui.copyWith(showHelp: !_state.ui.showHelp)));
      },
      goBack: () {
        if (_activePopup != null) {
          _activePopup = null;
          _setState(_state.copyWith(
              ui: _state.ui.copyWith(isPopupOpen: false, clearPopup: true)));
        } else if (_contextStack.isNotEmpty) {
          _contextStack.pop();
          _tuiApp.requestRender();
        }
      },
    );

    _keybindingRegistry.registerAll(bindings);
  }

  String get _currentContextName {
    switch (_state.ui.activeTab) {
      case SidebarTab.status:
        return 'status';
      case SidebarTab.files:
        return 'files';
      case SidebarTab.branches:
        return 'branches';
      case SidebarTab.commits:
        return 'commits';
      case SidebarTab.stash:
        return 'stash';
    }
  }

  Future<void> _handleInput(InputEvent event) async {
    // If popup is open, delegate to popup
    if (_activePopup != null) {
      _activePopup!.handleEvent(event);
      _tuiApp.requestRender();
      return;
    }

    // Try keybinding resolution
    final binding = _keybindingRegistry.resolve(event, _currentContextName);
    if (binding != null) {
      try {
        await binding.handler();
        _tuiApp.requestRender();
      } on GitCommandException catch (e) {
        _setError(e.stderr);
      } catch (e) {
        _setError(e.toString());
      }
      return;
    }

    // Try context stack
    if (_contextStack.isNotEmpty && _contextStack.handleEvent(event)) {
      _tuiApp.requestRender();
      return;
    }

    // Handle list navigation for the active tab
    if (event is KeyEvent) {
      await _handleTabNavigation(event);
    }
  }

  Future<void> _handleTabNavigation(KeyEvent event) async {
    switch (_state.ui.activeTab) {
      case SidebarTab.files:
        final newIndex = _calcListNav(
            event, _filesController.selectedIndex, _state.git.files.length);
        if (newIndex != null && newIndex != _filesController.selectedIndex) {
          _filesController.selectedIndex = newIndex;
          _diffContext.reset();
          await _filesController.loadDiffForSelected();
        }
      case SidebarTab.branches:
        _handleListNav(event, _branchesController.selectedIndex,
            _state.git.branches.length, (i) {
          _branchesController.selectedIndex = i;
        });
      case SidebarTab.commits:
        _handleListNav(event, _commitsController.selectedIndex,
            _state.git.commits.length, (i) {
          _commitsController.selectedIndex = i;
        });
      case SidebarTab.stash:
        _handleListNav(event, _stashController.selectedIndex,
            _state.git.stashes.length, (i) {
          _stashController.selectedIndex = i;
        });
      case SidebarTab.status:
        break;
    }
  }

  /// Returns the new index for a list navigation key, or null if not a nav key.
  int? _calcListNav(KeyEvent event, int current, int count) {
    if (count == 0) return null;
    switch (event.key) {
      case keyDown:
      case 'j':
        return (current + 1).clamp(0, count - 1);
      case keyUp:
      case 'k':
        return (current - 1).clamp(0, count - 1);
      case 'g':
        return 0;
      case 'G':
        return count - 1;
      case keyPageDown:
        return (current + 10).clamp(0, count - 1);
      case keyPageUp:
        return (current - 10).clamp(0, count - 1);
      default:
        return null;
    }
  }

  void _handleListNav(
      KeyEvent event, int current, int count, void Function(int) setIndex) {
    final newIndex = _calcListNav(event, current, count);
    if (newIndex != null) {
      setIndex(newIndex);
      _tuiApp.requestRender();
    }
  }

  void _showCommitPopup({required bool amend}) {
    _activePopup = CommitMessagePopup(
      amend: amend,
      onCommit: (message) async {
        _activePopup = null;
        _setState(_state.copyWith(
            ui: _state.ui.copyWith(isPopupOpen: false, clearPopup: true)));
        try {
          if (amend) {
            await _commitsController.amendCommit(message: message);
          } else {
            await _commitsController.commit(message);
          }
          await _refreshCoordinator.refresh(
              {RefreshScope.files, RefreshScope.commits, RefreshScope.status});
          _setStatus(amend ? 'Commit amended' : 'Committed');
        } on GitCommandException catch (e) {
          _setError('Commit failed: ${e.stderr}');
        }
      },
      onCancel: () {
        _activePopup = null;
        _setState(_state.copyWith(
            ui: _state.ui.copyWith(isPopupOpen: false, clearPopup: true)));
      },
    );
    _setState(_state.copyWith(
        ui: _state.ui.copyWith(isPopupOpen: true, popupId: 'commit')));
  }

  void _showBranchCreatePopup() {
    _activePopup = BranchCreatePopup(
      onCreate: (name) async {
        _activePopup = null;
        _setState(_state.copyWith(
            ui: _state.ui.copyWith(isPopupOpen: false, clearPopup: true)));
        try {
          await _branchesController.createBranch(name);
          _setStatus('Branch "$name" created');
        } on GitCommandException catch (e) {
          _setError('Branch creation failed: ${e.stderr}');
        }
      },
      onCancel: () {
        _activePopup = null;
        _setState(_state.copyWith(
            ui: _state.ui.copyWith(isPopupOpen: false, clearPopup: true)));
      },
    );
    _setState(_state.copyWith(
        ui: _state.ui.copyWith(isPopupOpen: true, popupId: 'branch_create')));
  }

  void _showConfirmation(
      String title, String message, Future<void> Function() onConfirm) {
    _activePopup = ConfirmationPopup(
      title: title,
      message: message,
      onConfirm: () async {
        _activePopup = null;
        _setState(_state.copyWith(
            ui: _state.ui.copyWith(isPopupOpen: false, clearPopup: true)));
        try {
          await onConfirm();
        } on GitCommandException catch (e) {
          _setError('$title failed: ${e.stderr}');
        }
      },
      onCancel: () {
        _activePopup = null;
        _setState(_state.copyWith(
            ui: _state.ui.copyWith(isPopupOpen: false, clearPopup: true)));
      },
    );
    _setState(_state.copyWith(
        ui: _state.ui.copyWith(isPopupOpen: true, popupId: 'confirmation')));
  }

  void _setStatus(String message) {
    _setState(_state.copyWith(
        ui: _state.ui.copyWith(statusMessage: message, clearError: true)));
  }

  void _setError(String message) {
    _setState(_state.copyWith(
        ui: _state.ui.copyWith(errorMessage: message, clearStatus: true)));
  }
}

/// Overlay widget that renders a popup on top of a background widget.
class _PopupOverlay extends Widget {
  final Widget background;
  final Widget popup;

  _PopupOverlay({required this.background, required this.popup});

  @override
  void render(Canvas canvas, Rect area) {
    background.render(canvas, area);
    popup.render(canvas, area);
  }

  @override
  (int, int) measure(BoxConstraints constraints) {
    return background.measure(constraints);
  }

  @override
  bool handleEvent(InputEvent event) {
    return popup.handleEvent(event);
  }

  @override
  List<Widget> get children => [background, popup];
}
