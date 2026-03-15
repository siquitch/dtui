import '../../git/models/git_branch.dart';
import 'controller.dart';

class BranchesController extends Controller {
  int selectedIndex = 0;

  BranchesController({
    required super.repo,
    required super.getState,
    required super.setState,
  });

  List<GitBranch> get branches => state.git.branches;

  GitBranch? get selectedBranch {
    if (branches.isEmpty || selectedIndex < 0 || selectedIndex >= branches.length) {
      return null;
    }
    return branches[selectedIndex];
  }

  Future<void> refresh() async {
    try {
      final branches = await repo.branches.getBranches();
      final current = await repo.status.getCurrentBranch();
      updateGitState((g) => g.copyWith(branches: branches, currentBranch: current));
      if (selectedIndex >= branches.length && branches.isNotEmpty) {
        selectedIndex = branches.length - 1;
      }
    } on Exception {
      // Handle gracefully
    }
  }

  Future<void> checkoutSelected() async {
    final branch = selectedBranch;
    if (branch == null || branch.isHead) return;
    await repo.branches.checkoutBranch(branch.name);
    await refresh();
  }

  Future<void> createBranch(String name) async {
    await repo.branches.createBranch(name);
    await refresh();
  }

  Future<void> deleteSelected({bool force = false}) async {
    final branch = selectedBranch;
    if (branch == null || branch.isHead) return;
    await repo.branches.deleteBranch(branch.name, force: force);
    await refresh();
  }

  Future<void> renameSelected(String newName) async {
    final branch = selectedBranch;
    if (branch == null) return;
    await repo.branches.renameBranch(branch.name, newName);
    await refresh();
  }

  Future<void> mergeSelected() async {
    final branch = selectedBranch;
    if (branch == null || branch.isHead) return;
    await repo.branches.mergeBranch(branch.name);
    await refresh();
  }
}
