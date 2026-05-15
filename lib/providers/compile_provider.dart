import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/models/tour_models.dart';
import '../core/utils/compile_service.dart';

part 'compile_provider.g.dart';

@riverpod
class CompileNotifier extends _$CompileNotifier {
  final _service = CompileService();

  @override
  AsyncValue<CompileResponse?> build(String chapterKey, int lessonIndex) {
    return const AsyncValue.data(null);
  }

  Future<void> runCode(String code) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.compile(code);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
