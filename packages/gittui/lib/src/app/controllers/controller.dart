import '../../git/git_repository.dart';
import '../state/app_state.dart';
import '../state/git_state.dart';
import '../state/ui_state.dart';

abstract class Controller {
  final GitRepository repo;
  AppState Function() getState;
  void Function(AppState) setState;

  Controller({
    required this.repo,
    required this.getState,
    required this.setState,
  });

  AppState get state => getState();

  void updateGitState(GitState Function(GitState) updater) {
    final current = getState();
    setState(current.copyWith(git: updater(current.git)));
  }

  void updateUiState(UiState Function(UiState) updater) {
    final current = getState();
    setState(current.copyWith(ui: updater(current.ui)));
  }
}
