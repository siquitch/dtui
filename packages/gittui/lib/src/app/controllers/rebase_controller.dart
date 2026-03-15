import 'controller.dart';

class RebaseController extends Controller {
  RebaseController({
    required super.repo,
    required super.getState,
    required super.setState,
  });

  Future<void> rebase(String onto) async {
    await repo.rebase.rebase(onto);
  }

  Future<void> abortRebase() async {
    await repo.rebase.rebaseAbort();
  }

  Future<void> continueRebase() async {
    await repo.rebase.rebaseContinue();
  }

  Future<void> skipRebase() async {
    await repo.rebase.rebaseSkip();
  }
}
