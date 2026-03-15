import 'git_state.dart';
import 'ui_state.dart';

class AppState {
  final GitState git;
  final UiState ui;

  const AppState({
    this.git = const GitState(),
    this.ui = const UiState(),
  });

  AppState copyWith({GitState? git, UiState? ui}) {
    return AppState(
      git: git ?? this.git,
      ui: ui ?? this.ui,
    );
  }
}
