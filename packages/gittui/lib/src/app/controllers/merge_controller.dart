import 'controller.dart';

class MergeController extends Controller {
  MergeController({
    required super.repo,
    required super.getState,
    required super.setState,
  });

  Future<void> abortMerge() async {
    await repo.runner.run('merge', ['--abort']);
  }

  Future<void> continueMerge() async {
    await repo.files.stageAll();
    await repo.runner.run('commit', ['--no-edit']);
  }
}
