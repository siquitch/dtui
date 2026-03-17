import '../../git/models/git_stash.dart';
import 'controller.dart';

class StashController extends Controller {
  int selectedIndex = 0;

  StashController({
    required super.repo,
    required super.getState,
    required super.setState,
  });

  List<GitStash> get stashes => state.git.stashes;

  GitStash? get selectedStash {
    if (stashes.isEmpty ||
        selectedIndex < 0 ||
        selectedIndex >= stashes.length) {
      return null;
    }
    return stashes[selectedIndex];
  }

  Future<void> refresh() async {
    try {
      final stashes = await repo.stash.getStashes();
      updateGitState((g) => g.copyWith(stashes: stashes));
      if (selectedIndex >= stashes.length && stashes.isNotEmpty) {
        selectedIndex = stashes.length - 1;
      }
    } on Exception {
      // Handle gracefully
    }
  }

  Future<void> stashChanges({String? message}) async {
    await repo.stash.stash(message: message);
    await refresh();
  }

  Future<void> popSelected() async {
    final stash = selectedStash;
    if (stash == null) return;
    await repo.stash.popStash(stash.index);
    await refresh();
  }

  Future<void> applySelected() async {
    final stash = selectedStash;
    if (stash == null) return;
    await repo.stash.applyStash(stash.index);
    await refresh();
  }

  Future<void> dropSelected() async {
    final stash = selectedStash;
    if (stash == null) return;
    await repo.stash.dropStash(stash.index);
    await refresh();
  }
}
