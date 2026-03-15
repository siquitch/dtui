import 'controllers/branches_controller.dart';
import 'controllers/commits_controller.dart';
import 'controllers/files_controller.dart';
import 'controllers/stash_controller.dart';
import 'controllers/status_controller.dart';

enum RefreshScope { status, files, branches, commits, stash, remotes, all }

class RefreshCoordinator {
  final FilesController filesController;
  final BranchesController branchesController;
  final CommitsController commitsController;
  final StashController stashController;
  final StatusController statusController;

  RefreshCoordinator({
    required this.filesController,
    required this.branchesController,
    required this.commitsController,
    required this.stashController,
    required this.statusController,
  });

  Future<void> refresh(Set<RefreshScope> scopes) async {
    if (scopes.contains(RefreshScope.all)) {
      await refreshAll();
      return;
    }

    final futures = <Future<void>>[];
    if (scopes.contains(RefreshScope.status)) {
      futures.add(statusController.refreshGitState());
    }
    if (scopes.contains(RefreshScope.files)) {
      futures.add(filesController.refresh());
    }
    if (scopes.contains(RefreshScope.branches)) {
      futures.add(branchesController.refresh());
    }
    if (scopes.contains(RefreshScope.commits)) {
      futures.add(commitsController.refresh());
    }
    if (scopes.contains(RefreshScope.stash)) {
      futures.add(stashController.refresh());
    }
    await Future.wait(futures);
  }

  Future<void> refreshAll() async {
    await Future.wait([
      statusController.refreshGitState(),
      filesController.refresh(),
      branchesController.refresh(),
      commitsController.refresh(),
      stashController.refresh(),
    ]);
  }
}
