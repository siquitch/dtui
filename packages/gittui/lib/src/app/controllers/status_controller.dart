import 'controller.dart';

class StatusController extends Controller {
  StatusController({
    required super.repo,
    required super.getState,
    required super.setState,
  });

  Future<void> refreshGitState() async {
    try {
      final branch = await repo.status.getCurrentBranch();
      final isMerging = await repo.status.isMerging();
      final isRebasing = await repo.status.isRebasing();
      updateGitState(
        (g) => g.copyWith(
          currentBranch: branch,
          isMerging: isMerging,
          isRebasing: isRebasing,
        ),
      );
    } on Exception {
      // Handle gracefully
    }
  }
}
